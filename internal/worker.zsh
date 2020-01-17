# invoked in worker: _p9k_worker_main <timeout>
function _p9k_worker_main() {
  local _p9k_worker_buf _p9k_worker_cmd
  while true; do
    if sysread -t $1 '_p9k_worker_buf[$#_p9k_worker_method+1]'; then
      _p9k_worker_cmd=${_p9k_worker_buf%%$'\x1e'*}
      if (( $#_p9k_worker_cmd != $#_p9k_worker_buf )); then
        _p9k_worker_buf[1,$#_p9k_worker_cmd+1]=""
        eval $_p9k_worker_cmd
      fi
    else
      (( $? == 4 )) || return
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
typeset -gA _p9k__worker_functions
typeset -gA _p9k__worker_requests

# invoked in master: _p9k_worker_reply <list>...
#
# worker also has _p9k_worker_reply but its implemented as _p9k_worker_reply_remote
function _p9k_worker_reply() { eval $1 }

# invoked in worker where it's called _p9k_worker_reply
# usage: _p9k_worker_reply <list>
function _p9k_worker_reply_remote() { print -rn -- e$1$'\x1e' }

# invoked in worker: _p9k_worker_done <request-id>
function _p9k_worker_done() { print -rn -- d$1$'\x1e' }

# invoked in master: _p9k_worker_eval <list>
function _p9k_worker_eval() {
  print -rnu $_p9k__worker_req_fd -- $1$'\x1e' && return
  _p9k_worker_stop
  return 1
}

# invoked in master: _p9k_worker_send_params [param]...
function _p9k_worker_send_params() {
  [[ -z $_p9k__worker_resp_fd || $# == 0 ]] && return
  if [[ -n $_p9k__worker_req_fd ]]; then
    {
      typeset -p -- $* && print -rn -- $'\x1e' && return
    } >&$_p9k__worker_req_fd
    _p9k_worker_stop
    return 1
  else
    _p9k__worker_params+=($*)
  fi
}

# invoked in master: _p9k_worker_invoke <request-id> <func> [arg]...
function _p9k_worker_invoke() {
  if [[ -n $_p9k__worker_resp_fd ]]; then
    if [[ -n $_p9k__worker_req_fd ]]; then
      local req
      if (( ! $+_p9k__worker_functions[$2] )); then
        req+="function $2() { $functions[$2] ; }"$'\n'
        _p9k__worker_functions[$2]=
      fi
      if (( ! $+_p9k__worker_requests[$1] )); then
        req+="${(j: :)${(@q)${@:2}}}"$'\n'
        _p9k__worker_requests[$1]=
      else
        _p9k__worker_requests[$1]="${(j: :)${(@q)${@:2}}}"
      fi
      if [[ -n $req ]]; then
        _p9k_worker_eval $req"_p9k_worker_done ${(q)1}"
      fi
    else
      _p9k__worker_functions[$2]=
      _p9k__worker_requests[$1]="${(j: :)${(@q)${@:2}}}"
    fi
  else
    "${@:2}"
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
  _p9k__worker_requests=()
  _p9k__worker_functions=()
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
          local req=$_p9k__worker_requests[$arg]
          if [[ -n $req ]]; then
            _p9k__worker_requests[$arg]=
            _p9k_worker_eval $req$'\n'"_p9k_worker_done ${(q)arg}"                    || return
          else
            unset "_p9k__worker_requests[$arg]"
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
              function _p9k_worker_reply() { $functions[_p9k_worker_reply_remote] }"  || return
            local f
            for f in _p9k_worker_done _p9k_worker_main ${(k)_p9k__worker_functions}; do
              print -r -- "function $f() { $functions[$f] }"                          || return
            done
            if (( $#_p9k__worker_params )); then
              typeset -p -- $_p9k__worker_params                                      || return
              _p9k__worker_params=()
            fi
            local id list
            for id list in "${(@kv)_p9k__worker_requests}"; do
              print -rl -- $list "_p9k_worker_done ${(q)id}"                          || return
              _p9k__worker_requests[$id]=
            done
            if (( _POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME )); then
              print -r -- "
                function _p9k_worker_on_timeout() { _p9k_worker_reply '' }
                _p9k_worker_main 1"                                                   || return
            else
              print -r -- "_p9k_worker_main -1"                                       || return
            fi
            print -rn -- $'\x1e'                                                      || return
          } >&$_p9k__worker_req_fd
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
    trace=

    local fifo=$_p9k__worker_file_prefix.fifo
    local cmd='
      emulate zsh
      { mkfifo '${(q)fifo}' && exec >&4 && echo -n "s$$\x1e" && exec 0<'${(q)fifo}' || exit } always { rm -f '${(q)fifo}' }
      IFS= read -rd $'\''\x1e'\'' && eval $REPLY'
    local setsid=${commands[setsid]:-/usr/local/opt/util-linux/bin/setsid}
    [[ -x $setsid ]] && setsid=${(q)setsid} || setsid=
    local zsh=${${:-/proc/self/exe}:A}
    [[ -x $zsh ]] || zsh=zsh
    cmd="$setsid ${(q)zsh} --nobgnice --noaliases -${trace}dfc ${(q)cmd} &!"
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
_POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME=1
typeset -F _p9k__last_prompt_update_time

zmodload zsh/datetime
zmodload zsh/system
autoload -Uz add-zsh-hook

typeset -F start_time=EPOCHREALTIME
_p9k_worker_start
echo -E - $((1000*(EPOCHREALTIME-start_time)))

function compute_foo() {
  local f="${(q+)1} ${(q+)bar} $((foo_counter++))"
  _p9k_worker_reply "typeset -g foo=${(q)f}"
}

bar='rofl $  {'

_p9k_worker_send_params bar

() {
  local -i i
  for i in {1..10}; do
    _p9k_worker_invoke f compute_foo $i
  done
}

RPROMPT='$foo %*'

function in_worker() {
  _p9k_worker_reply 'echo roundtrip: $((1000*(EPOCHREALTIME-'$1'))) >>/tmp/log'
}

_p9k_worker_invoke w in_worker $EPOCHREALTIME
# for i in {1..100}; do _p9k_worker_invoke w$i in_worker $EPOCHREALTIME; done
