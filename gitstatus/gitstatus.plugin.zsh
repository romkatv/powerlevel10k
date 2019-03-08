[[ -o interactive ]] || return

zmodload zsh/datetime || return

# Retrives status of a git repo from a directory under its working tree.
#
#   -d STR    Directory to query. Defaults to $PWD. Must be absolute.
#   -c STR    Callback function to call once the results are available. Called only after
#             gitstatus_query returns 0 with VCS_STATUS_RESULT=tout.
#   -t FLOAT  Timeout in seconds. Will block for at most this long. If no results are
#             available by then: if -c isn't specified, will return 1; otherwise will set
#             VCS_STATUS_RESULT=tout and return 0.
#
# On success sets VCS_STATUS_RESULT to one of the following values:
#
#   tout         Timed out waiting for data; will call the user-specified callback later.
#   norepo-sync  The directory isn't a git repo.
#   ok-sync      The directory is a git repo.
#
# When the callback is called VCS_STATUS_RESULT s set to one of the following values:
#
#   norepo-async  The directory isn't a git repo.
#   ok-async      The directory is a git repo.
#
# If VCS_STATUS_RESULT is ok-sync or ok-async, additional variables are set:
#
#   VCS_STATUS_LOCAL_BRANCH    Local branch name. Not empty.
#   VCS_STATUS_REMOTE_BRANCH   Upstream branch name. Can be empty.
#   VCS_STATUS_REMOTE_URL      Remote URL. Can be empty.
#   VCS_STATUS_ACTION          Repository state, A.K.A. action. Can be empty.
#   VCS_STATUS_HAS_STAGED      1 if there are staged changes, 0 otherwise.
#   VCS_STATUS_HAS_UNSTAGED    1 if there are unstaged changes, 0 if there aren't, -1 if unknown.
#   VCS_STATUS_HAS_UNTRACKED   1 if there are untracked files, 0 if there aren't, -1 if unknown.
#   VCS_STATUS_COMMITS_AHEAD   Number of commits the current branch is ahead of upstream.
#                              Non-negative integer.
#   VCS_STATUS_COMMITS_BEHIND  Number of commits the current branch is behind upstream. Non-negative
#                              integer.
#   VCS_STATUS_STASHES         Number of stashes. Non-negative integer.
#   VCS_STATUS_WORKDIR         Git repo working directory. Not empty.
#   VCS_STATUS_ALL             All of the above in an array. The order of elements is unspecified.
#                              More elements can be added in the future.
#
# The point of reporting -1 as unstaged and untracked is to allow the command to skip scanning
# files in large repos. See -m flag of gitstatus_start.
#
#       !!!!! WARNING: CONCURRENT CALLS WITH THE SAME NAME ARE NOT ALLOWED !!!!!
#
# It's illegal to call `gitstatus_query NAME` if `gitstatus_query NAME` is running concurrently in
# the same interactive shell or its child, or if the callback for the last timed out request hasn't
# fired yet. If you need to issue concurrent requests, use different NAME arguments.
function gitstatus_query() {
  emulate -L zsh
  setopt err_return no_unset

  local opt
  local dir=$PWD
  local callback=''
  local -F timeout=-1
  while true; do
    getopts "d:c:t:" opt || break
    case $opt in
      d) dir=$OPTARG;;
      c) callback=$OPTARG;;
      t) timeout=$OPTARG;;
      ?) return 1;;
      done) break;;
    esac
  done
  (( OPTIND == ARGC )) || { echo "usage: gitstatus_query [OPTION]... NAME" >&2; return 1 }
  local name=${*[$OPTIND]}

  [[ -v GITSTATUS_DAEMON_PID_${name} ]]

  local -i req_fd
  local req_fd_var=_GITSTATUS_REQ_FD_${name}
  local client_pid_var=_GITSTATUS_CLIENT_PID_${name}

  [[ ${(P)client_pid_var} == $$ ]] && {
    req_fd=${(P)req_fd_var}
  } || {
    local req_fifo_var=_GITSTATUS_REQ_FIFO_${name}
    local resp_fifo_var=_GITSTATUS_RESP_FIFO_${name}
    local resp_fd_var=_GITSTATUS_RESP_FD_${name}
    local -i resp_fd
    exec {req_fd}<>${(P)req_fifo_var}
    exec {resp_fd}<>${(P)resp_fifo_var}
    typeset -g $client_pid_var=$$
    typeset -g $req_fd_var=$req_fd
    typeset -g $resp_fd_var=$resp_fd
    typeset -giH $client_pid_var=$client_pid
    typeset -gfH _gitstatus_process_response_${name}() {
      _gitstatus_process_response ${0#_gitstatus_process_response_} 0 ''
    }
    zle -F $resp_fd _gitstatus_process_response_${name}
  }

  local -r req_id="$EPOCHREALTIME"
  echo -nE "${req_id} ${callback}"$'\x1f'"${dir}"$'\x1e' >&$req_fd

  while true; do
    _gitstatus_process_response $name $timeout $req_id
    [[ $VCS_STATUS_RESULT == *-async ]] || break
  done

  [[ $VCS_STATUS_RESULT != tout || -n $callback ]]
}

typeset -fH _gitstatus_process_response() {
  emulate -L zsh
  setopt err_return no_unset

  local name=$1
  local -F timeout=$2
  local req_id=$3
  local resp_fd_var=_GITSTATUS_RESP_FD_${name}

  typeset -ga VCS_STATUS_ALL
  typeset -g VCS_STATUS_RESULT
  (( timeout >= 0 )) && local -a t=(-t $timeout) || local -a t=()
  IFS=$'\x1f' read -rd $'\x1e' -u ${(P)resp_fd_var} $t -A VCS_STATUS_ALL || {
    VCS_STATUS_RESULT=tout
    unset VCS_STATUS_ALL
    return
  }

  local -a header=("${(@Q)${(z)VCS_STATUS_ALL[1]}}")
  [[ ${header[1]} == $req_id ]] && local -i ours=1 || local -i ours=0
  shift header
  [[ ${VCS_STATUS_ALL[2]} == 1 ]] && {
    shift 2 VCS_STATUS_ALL
    (( ours )) && VCS_STATUS_RESULT=ok-sync || VCS_STATUS_RESULT=ok-async
    typeset -g  VCS_STATUS_LOCAL_BRANCH="${VCS_STATUS_ALL[1]}"
    typeset -g  VCS_STATUS_REMOTE_BRANCH="${VCS_STATUS_ALL[2]}"
    typeset -g  VCS_STATUS_REMOTE_URL="${VCS_STATUS_ALL[3]}"
    typeset -g  VCS_STATUS_ACTION="${VCS_STATUS_ALL[4]}"
    typeset -gi VCS_STATUS_HAS_STAGED="${VCS_STATUS_ALL[5]}"
    typeset -gi VCS_STATUS_HAS_UNSTAGED="${VCS_STATUS_ALL[6]}"
    typeset -gi VCS_STATUS_HAS_UNTRACKED="${VCS_STATUS_ALL[7]}"
    typeset -gi VCS_STATUS_COMMITS_AHEAD="${VCS_STATUS_ALL[8]}"
    typeset -gi VCS_STATUS_COMMITS_BEHIND="${VCS_STATUS_ALL[9]}"
    typeset -gi VCS_STATUS_STASHES="${VCS_STATUS_ALL[10]}"
    typeset -g  VCS_STATUS_WORKDIR="${VCS_STATUS_ALL[11]}"
  } || {
    (( ours )) && VCS_STATUS_RESULT=norepo-sync || VCS_STATUS_RESULT=norepo-async
    unset VCS_STATUS_ALL
    unset VCS_STATUS_LOCAL_BRANCH
    unset VCS_STATUS_REMOTE_BRANCH
    unset VCS_STATUS_REMOTE_URL
    unset VCS_STATUS_ACTION
    unset VCS_STATUS_HAS_STAGED
    unset VCS_STATUS_HAS_UNSTAGED
    unset VCS_STATUS_HAS_UNTRACKED
    unset VCS_STATUS_COMMITS_AHEAD
    unset VCS_STATUS_COMMITS_BEHIND
    unset VCS_STATUS_STASHES
    unset VCS_STATUS_WORKDIR
  }

  (( ! ours )) && (( #header )) && emulate -L zsh && "${header[@]}" || true
}

# Usage: gitstatus_start [OPTION]... NAME
#
#   -t FLOAT  Fail the self-check on initialization if not getting a response from gitstatusd for
#             this this many seconds. Defaults to 5.
#   -m INT    Report -1 unstaged and untracked if there are more than this many files in the index.
#             Negative value means infinity. Defaults to -1.
function gitstatus_start() {
  emulate -L zsh
  setopt err_return no_unset
  unsetopt bg_nice

  local opt
  local -F timeout=5
  local -i max_dirty=-1
  while true; do
    getopts "t:m:" opt || break
    case $opt in
      t) timeout=$OPTARG;;
      m) max_dirty=$OPTARG;;
      ?) return 1;;
      done) break;;
    esac
  done

  (( timeout > 0 )) || { echo "invalid -t: $timeout" >&2; return 1 }
  (( OPTIND == ARGC )) || { echo "usage: gitstatus_start [OPTION]... NAME" >&2; return 1 }
  local name=${*[$OPTIND]}

  [[ ! -v GITSTATUS_DAEMON_PID_${name} ]] || return 0

  function gitstatus_arch() {
    local kernel && kernel=$(uname -s) && [[ -n $kernel ]]
    local arch && arch=$(uname -m) && [[ -n $arch ]]
    echo -E "${kernel:l}-${arch:l}"
  }

  local daemon && daemon=${GITSTATUS_DAEMON:-${${(%):-%x}:A:h}/bin/gitstatusd-$(gitstatus_arch)}
  [[ -f $daemon ]] || { echo "file not found: $daemon" >&2 && return 1 }

  local req_fifo resp_fifo log
  local -i req_fd resp_fd daemon_pid

  function start() {
    req_fifo=$(mktemp -u "${TMPDIR:-/tmp}"/gitstatus.$$.pipe.req.XXXXXXXXXX)
    resp_fifo=$(mktemp -u "${TMPDIR:-/tmp}"/gitstatus.$$.pipe.resp.XXXXXXXXXX)
    mkfifo $req_fifo
    mkfifo $resp_fifo
    exec {req_fd}<>$req_fifo
    exec {resp_fd}<>$resp_fifo
    typeset -gfH _gitstatus_process_response_${name}() {
      _gitstatus_process_response ${0#_gitstatus_process_response_} 0 ''
    }
    zle -F $resp_fd _gitstatus_process_response_${name}

    log=$(mktemp "${TMPDIR:-/tmp}"/gitstatus.$$.log.XXXXXXXXXX)

    # We use `zsh -c` instead of plain {} or () to work around bugs in zplug. It hangs on startup.
    zsh -c "
      ${(q)daemon} --dirty-max-index-size=${(q)max_dirty} --parent-pid=$$
      echo -nE $'bye\x1f0\x1e'
      rm -f ${(q)req_fifo} ${(q)resp_fifo}
    " <&$req_fd >&$resp_fd 2>$log &!

    daemon_pid=$!

    local reply
    echo -nE $'hello\x1f\x1e' >&$req_fd
    IFS='' read -r -d $'\x1e' -u $resp_fd -t $timeout reply
    [[ $reply == $'hello\x1f0' ]]
  }

  start && {
    typeset -g    GITSTATUS_DAEMON_LOG_${name}=$log
    typeset -gi   GITSTATUS_DAEMON_PID_${name}=$daemon_pid
    typeset -gH  _GITSTATUS_REQ_FIFO_${name}=$req_fifo
    typeset -gH  _GITSTATUS_RESP_FIFO_${name}=$resp_fifo
    typeset -giH _GITSTATUS_REQ_FD_${name}=$req_fd
    typeset -giH _GITSTATUS_RESP_FD_${name}=$resp_fd
    typeset -giH _GITSTATUS_CLIENT_PID_${name}=$$
  } || {
    echo "gitstatus failed to initialize" >&2
    [[ -n $daemon_pid ]] && kill $daemon_pid &>/dev/null || true
    [[ -n $req_fd ]] && exec {req_fd}>&- || true
    [[ -n $resp_fd ]] && { zle -F $resp_fd || true } && { exec {resp_fd}>&- || true}
    rm -f $req_fifo $resp_fifo
    return 1
  }
}

# Usage: gitstatus_check NAME.
#
# Returns 0 if and only if `gitstatus_start NAME` has succeeded previously.
# If it returns non-zero, gitstatus_query NAME is guaranteed to return non-zero.
function gitstatus_check() {
  local name=$1
  [[ -v GITSTATUS_DAEMON_PID_${name} ]]
}
