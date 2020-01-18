# invoked in worker: _p9k_worker_main <timeout>
function _p9k_worker_main() {
  zmodload zsh/system   || return
  zmodload zsh/zselect  || return
  zselect -t0
  (( $? == 1 ))         || return

  local req fd
  local -A inflight  # fd => id$'\x1f'sync
  local -a ready
  local _p9k_worker_tmout  # empty or non-negative int, in hundredths of a second
  while true; do
    if zselect -a ready ${_p9k_worker_tmout:+-t$_p9k_worker_tmout} 0 ${(k)inflight}; then
      [[ $ready[1] == -r ]] || return
      for fd in ${ready:1}; do
        if [[ $fd == 0 ]]; then
          local buf=
          while true; do
            sysread -t 0 'buf[$#buf+1]'  && continue
            (( $? == 4 ))                || return
            [[ $buf[-1] == (|$'\x1e') ]] && break
            sysread 'buf[$#buf+1]'       || return
          done
          for req in ${(ps:\x1e:)buf}; do
            local parts=("${(@ps:\x1f:)req}")  # id cond async sync
            if () { eval $parts[2] }; then
              if [[ -n $parts[3] ]]; then
                sysopen -r -o cloexec -u fd <(
                  local REPLY=; eval $parts[3]; print -rn -- $REPLY) || return
                inflight[$fd]=$parts[1]$'\x1f'$parts[4]
                continue
              fi
              local REPLY=
              () { eval $parts[4] }
            fi
            if [[ -n $parts[1] ]]; then
              print -rn -- d$parts[1]$'\x1e' || return
            fi
          done
        else
          local REPLY=
          while true; do
            sysread -i $fd 'REPLY[$#REPLY+1]' && continue
            (( $? == 5 ))                     || return
            break
          done
          local parts=("${(@ps:\x1f:)inflight[$fd]}")  # id sync
          () { eval $parts[2] }
          if [[ -n $parts[1] ]]; then
            print -rn -- d$parts[1]$'\x1e' || return
          fi
          unset "inflight[$fd]"
        fi
      done
    else
      (( $? == 1 )) || return
      (( $+functions[_p9k_worker_on_timeout] )) && _p9k_worker_on_timeout
    fi
  done
}

typeset -g  _p9k__worker_pid
typeset -g  _p9k__worker_req_fd
typeset -g  _p9k__worker_resp_fd
typeset -g  _p9k__worker_shell_pid
typeset -g  _p9k__worker_file_prefix
typeset -ga _p9k__worker_params
typeset -gA _p9k__worker_request_map
typeset -ga _p9k__worker_request_queue

# invoked in master: _p9k_worker_reply <list>...
#
# worker also has _p9k_worker_reply but its implemented as _p9k_worker_reply_remote
function _p9k_worker_reply() { eval $1 }

# invoked in worker where it's called _p9k_worker_reply
# usage: _p9k_worker_reply <list>
function _p9k_worker_reply_remote() { print -rn -- e$1$'\x1e' }

# invoked in worker: _p9k_worker_on_timeout
function _p9k_worker_on_timeout() {
  _p9k_worker_tmout=
  _p9k_worker_reply _p9k_worker_keep_alive
}

# invoked in master: _p9k_worker_keep_alive
function _p9k_worker_keep_alive() {
  _p9k_worker_invoke "" "_p9k_worker_tmout=100" "" ""
}

# invoked in master: _p9k_worker_send_params [param]...
function _p9k_worker_send_params() {
  [[ -z $_p9k__worker_resp_fd || $# == 0 ]] && return
  if [[ -n $_p9k__worker_req_fd ]]; then
    {
      print -rn -- $'\x1f' && typeset -p -- $* && print -rn -- $'\x1f\x1f\x1e' && return
    } >&$_p9k__worker_req_fd
    _p9k_worker_stop
    return 1
  else
    _p9k__worker_params+=($*)
  fi
}

# invoked in master: _p9k_worker_invoke <request-id> <cond> <async> <sync>
function _p9k_worker_invoke() {
  if [[ -n $_p9k__worker_resp_fd ]]; then
    local req=$1$'\x1f'$2$'\x1f'$3$'\x1f'$4$'\x1e'
    if [[ -n $_p9k__worker_req_fd && $+_p9k__worker_request_map[$1] == 0 ]]; then
      [[ -n $1 ]] && _p9k__worker_request_map[$1]=
      print -rnu $_p9k__worker_req_fd -- $req
      return
    fi
    if [[ -n $1 ]]; then
      (( $+_p9k__worker_request_map[$1] )) || _p9k__worker_request_queue+=$1
      _p9k__worker_request_map[$1]=$req
    else
      _p9k__worker_request_queue+=$req
    fi
  else
    if () { eval $2 }; then
      local REPLY=
      () { eval $3 }
      () { eval $4 }
    fi
  fi
}

function _p9k_worker_cleanup() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases
  [[ $_p9k__worker_shell_pid == $sysparams[pid] ]] && _p9k_worker_stop
  return 0
}

function _p9k_worker_stop() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases
  add-zsh-hook -D zshexit _p9k_worker_cleanup
  [[ -n $_p9k__worker_resp_fd     ]] && zle -F $_p9k__worker_resp_fd
  [[ -n $_p9k__worker_resp_fd     ]] && exec {_p9k__worker_resp_fd}>&-
  [[ -n $_p9k__worker_req_fd      ]] && exec {_p9k__worker_req_fd}>&-
  [[ -n $_p9k__worker_pid         ]] && kill -- -$_p9k__worker_pid 2>/dev/null
  _p9k__worker_pid=
  _p9k__worker_req_fd=
  _p9k__worker_resp_fd=
  _p9k__worker_shell_pid=
  _p9k__worker_params=()
  _p9k__worker_request_map=()
  _p9k__worker_request_queue=()
  return 0
}

function _p9k_worker_receive() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases

  {
    (( $# <= 1 )) || return

    local buf resp reset
    while true; do
      sysread -t 0 -i $_p9k__worker_resp_fd 'buf[$#buf+1]' && continue
      (( $? == 4 ))                                                                   || return
      [[ $buf[-1] == (|$'\x1e') ]] && break
      sysread -i $_p9k__worker_resp_fd 'buf[$#buf+1]'                                 || return
    done

    for resp in ${(ps:\x1e:)buf}; do
      local arg=$resp[2,-1]
      case $resp[1] in
        d)
          local req=$_p9k__worker_request_map[$arg]
          if [[ -n $req ]]; then
            _p9k__worker_request_map[$arg]=
            print -rnu $_p9k__worker_req_fd -- $req                                   || return
          else
            unset "_p9k__worker_request_map[$arg]"
          fi
        ;;
        e)
          if (( start_time )); then
            local -F end_time=EPOCHREALTIME
            local -F3 latency=$((1000*(end_time-start_time)))
            echo "latency: $latency ms" >>/tmp/log
            start_time=0
          fi
          reset=1
          () { eval $arg }
        ;;
        s)
          [[ -z $_p9k__worker_pid ]]                                                  || return
          [[ $arg == <1->        ]]                                                   || return
          _p9k__worker_pid=$arg
          sysopen -w -o cloexec -u _p9k__worker_req_fd $_p9k__worker_file_prefix.fifo || return
          {
            print -r -- "
              emulate -L zsh
              setopt no_hist_expand extended_glob no_prompt_bang prompt_percent prompt_subst no_aliases
              zmodload zsh/system
              zmodload zsh/datetime
              function _p9k_worker_main()  { $functions[_p9k_worker_main] }
              function _p9k_worker_reply() { $functions[_p9k_worker_reply_remote] }"  || return
            if (( _POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME )); then
              print -r -- "function _p9k_worker_on_timeout() {
                $functions[_p9k_worker_on_timeout] }"                                 || return
            fi
            print -r -- "_p9k_worker_main"                                            || return
            print -rn -- $'\x1e'                                                      || return
            if (( $#_p9k__worker_params )); then
              print -rn -- $'\x1f'                                                    || return
              typeset -p -- $_p9k__worker_params                                      || return
              print -rn -- $'\x1f\x1f\x1e'                                            || return
              _p9k__worker_params=()
            fi
            local req=
            for req in $_p9k__worker_request_queue; do
              if [[ $req != *$'\x1e' ]]; then
                local id=$req
                req=$_p9k__worker_request_map[$id]
                _p9k__worker_request_map[$id]=
              fi
              print -rnu $_p9k__worker_req_fd -- $req                                 || return
            done
            _p9k__worker_request_queue=()
          } >&$_p9k__worker_req_fd
          (( _POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME )) && _p9k_worker_keep_alive
        ;;
        *)
          return 1
        ;;
      esac
    done

    if (( reset ||
          _POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME &&
            _p9k__last_prompt_update_time < EPOCHREALTIME - 0.8 )); then
      _p9k_reset_prompt
    fi
    return 0
  } always {
    (( $? )) && _p9k_worker_stop
  }
}

function _p9k_worker_start() {
  {
    [[ -n $_p9k__worker_resp_fd ]] && return
    _p9k__worker_file_prefix=${TMPDIR:-/tmp}/p10k.worker.$EUID.$$.$EPOCHSECONDS

    if [[ -n $POWERLEVEL9K_WORKER_LOG_LEVEL ]]; then
      local trace=x
      local log_file=$file_prefix.log
    else
      local trace=
      local log_file=/dev/null
    fi

    log_file=/tmp/log  # todo: remove
    trace=x

    local fifo=$_p9k__worker_file_prefix.fifo
    local cmd=(
      'emulate zsh'
      '{ mkfifo '${(q)fifo}' && exec >&4 && echo -n "s$$\x1e" && exec 0<'${(q)fifo}' || exit } always { rm -f '${(q)fifo}' }'
      'IFS= read -rd $'\''\x1e'\'' && eval $REPLY')
    local setsid=${commands[setsid]:-/usr/local/opt/util-linux/bin/setsid}
    [[ -x $setsid ]] && setsid=${(q)setsid} || setsid=
    local zsh=${${:-/proc/self/exe}:A}
    [[ -x $zsh ]] || zsh=zsh
    cmd="$setsid ${(q)zsh} --nobgnice --noaliases -${trace}dfc ${(q)${(j:; :)cmd}} &!"
    sysopen -r -o cloexec -u _p9k__worker_resp_fd <(
      $zsh --nobgnice --noaliases -${trace}dfmc $cmd </dev/null 4>&1 &>>$log_file &!) || return
    zle -F $_p9k__worker_resp_fd _p9k_worker_receive
    _p9k__worker_shell_pid=$sysparams[pid]
    add-zsh-hook zshexit _p9k_worker_cleanup
  } always {
    (( $? )) && _p9k_worker_stop
  }
}

# todo: remove
function _p9k_reset_prompt() {
  zle && zle reset-prompt && zle -R && _p9k__last_prompt_update_time=EPOCHREALTIME
}

emulate -L zsh -o prompt_subst # -o xtrace

POWERLEVEL9K_WORKER_LOG_LEVEL=DEBUG
_POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME=0
typeset -F _p9k__last_prompt_update_time

zmodload zsh/datetime
zmodload zsh/system
autoload -Uz add-zsh-hook

typeset -F start_time=EPOCHREALTIME
_p9k_worker_start
echo -E - $((1000*(EPOCHREALTIME-start_time)))

function foo_cond() {
  typeset -gi foo_counter
  typeset -g foo="[$bar] cond $1 $((foo_counter++))"
}

function foo_async() {
  sleep 1
  REPLY="$foo / async $1"
}

function foo_sync() {
  REPLY+=" / sync $1"
  _p9k_worker_reply "typeset -g foo=${(q)REPLY}"
}

() {
  typeset -g RPROMPT='$foo %*'
  typeset -g bar='lol'
  _p9k_worker_send_params bar

  local f
  for f in foo_{cond,async,sync}; do
    _p9k_worker_invoke "" "function $f() { $functions[$f] }" "" ""
  done

  () {
    local -i i
    for i in {1..10}; do
      _p9k_worker_invoke foo$i "foo_cond c$i\$\{" "foo_async a$i\$\{" "foo_sync s$i\$\{"
    done
  }
}

function in_worker() {
  _p9k_worker_reply 'echo roundtrip: $((1000*(EPOCHREALTIME-'$1'))) >>/tmp/log'
}

_p9k_worker_invoke "" "function in_worker() { $functions[in_worker] }" "" ""
_p9k_worker_invoke w "in_worker $EPOCHREALTIME" "" ""
# for i in {1..100}; do _p9k_worker_invoke w$i "in_worker $EPOCHREALTIME"; done

# TODO:
#
# - Segment API: _p9k_prompt_foo_worker_{params,cond,async,sync}.
# - _p9k_worker_request -- cacheable variable that contains full request to worker.
# - _p9k_set_prompt sends stuff to worker or evals it.
# - _p9k_on_expand has _REALTIME check at the top and sends keep-alive to worker.
