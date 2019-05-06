# Copyright 2019 Roman Perepelitsa.
#
# This file is part of GitStatus. It provides ZSH bindings.
#
# GitStatus is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GitStatus is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GitStatus. If not, see <https://www.gnu.org/licenses/>.
#
# ------------------------------------------------------------------
#
# Example: Start gitstatusd, send it a request, wait for response and print it.
#
#   source gitstatus.plugin.zsh
#   gitstatus_start MY
#   gitstatus_query -d $PWD MY
#   set | egrep '^VCS_STATUS'
#
# Output:
#
#   VCS_STATUS_ACTION=''
#   VCS_STATUS_COMMIT=6e86ec135bf77875e222463cbac8ef72a7e8d823
#   VCS_STATUS_COMMITS_AHEAD=0
#   VCS_STATUS_COMMITS_BEHIND=0
#   VCS_STATUS_HAS_STAGED=0
#   VCS_STATUS_HAS_UNSTAGED=1
#   VCS_STATUS_HAS_UNTRACKED=1
#   VCS_STATUS_LOCAL_BRANCH=master
#   VCS_STATUS_REMOTE_BRANCH=master
#   VCS_STATUS_REMOTE_NAME=origin
#   VCS_STATUS_REMOTE_URL=git@github.com:romkatv/powerlevel10k.git
#   VCS_STATUS_RESULT=ok-sync
#   VCS_STATUS_STASHES=0
#   VCS_STATUS_TAG=''
#   VCS_STATUS_WORKDIR=/home/romka/.oh-my-zsh/custom/themes/powerlevel10k

[[ -o interactive ]] || return
autoload -Uz add-zsh-hook && zmodload zsh/datetime zsh/system || return

# Retrives status of a git repo from a directory under its working tree.
#
## Usage: gitstatus_query [OPTION]... NAME
#
#   -d STR    Directory to query. Defaults to ${${GIT_DIR:-$PWD}:a}. Must be absolute.
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
# When the callback is called VCS_STATUS_RESULT is set to one of the following values:
#
#   norepo-async  The directory isn't a git repo.
#   ok-async      The directory is a git repo.
#
# If VCS_STATUS_RESULT is ok-sync or ok-async, additional variables are set:
#
#   VCS_STATUS_WORKDIR         Git repo working directory. Not empty.
#   VCS_STATUS_COMMIT          Commit hash that HEAD is pointing to. Either 40 hex digits or empty
#                              if there is no HEAD (empty repo).
#   VCS_STATUS_LOCAL_BRANCH    Local branch name or empty if not on a branch.
#   VCS_STATUS_REMOTE_NAME     The remote name, e.g. "upstream" or "origin".
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
#   VCS_STATUS_TAG             The last tag (in lexicographical order) that points to the same
#                              commit as HEAD.
#
# The point of reporting -1 as unstaged and untracked is to allow the command to skip scanning
# files in large repos. See -m flag of gitstatus_start.
#
# gitstatus_query returns an error if gitstatus_start hasn't been called in the same shell or
# the call had failed.
#
#       !!!!! WARNING: CONCURRENT CALLS WITH THE SAME NAME ARE NOT ALLOWED !!!!!
#
# It's illegal to call gitstatus_query if the last asynchronous call with the same NAME hasn't
# completed yet. If you need to issue concurrent requests, use different NAME arguments.
function gitstatus_query() {
  emulate -L zsh
  setopt err_return no_unset

  local opt
  local dir=${${GIT_DIR:-$PWD}:a}
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

  [[ -n ${(P)${:-GITSTATUS_DAEMON_PID_${name}}:-} ]]

  # Verify that gitstatus_query is running in the same process that ran gitstatus_start.
  local client_pid_var=_GITSTATUS_CLIENT_PID_${name}
  [[ ${(P)client_pid_var} == $$ ]]

  local req_fd_var=_GITSTATUS_REQ_FD_${name}
  local -i req_fd=${(P)req_fd_var}
  local -r req_id="$EPOCHREALTIME"
  echo -nE "${req_id} ${callback}"$'\x1f'"${dir}"$'\x1e' >&$req_fd

  while true; do
    _gitstatus_process_response $name $timeout $req_id
    [[ $VCS_STATUS_RESULT == *-async ]] || break
  done

  [[ $VCS_STATUS_RESULT != tout || -n $callback ]]
}

function _gitstatus_process_response() {
  emulate -L zsh
  setopt err_return no_unset

  local name=$1
  local -F timeout=$2
  local req_id=$3
  local resp_fd_var=_GITSTATUS_RESP_FD_${name}

  typeset -g VCS_STATUS_RESULT
  (( timeout >= 0 )) && local -a t=(-t $timeout) || local -a t=()
  local -a resp
  IFS=$'\x1f' read -rd $'\x1e' -u ${(P)resp_fd_var} $t -A resp || {
    VCS_STATUS_RESULT=tout
    return
  }

  local -a header=("${(@Q)${(z)resp[1]}}")
  [[ ${header[1]} == $req_id ]] && local -i ours=1 || local -i ours=0
  shift header
  [[ ${resp[2]} == 1 ]] && {
    (( ours )) && VCS_STATUS_RESULT=ok-sync || VCS_STATUS_RESULT=ok-async
    typeset -g  VCS_STATUS_WORKDIR="${resp[3]}"
    typeset -g  VCS_STATUS_COMMIT="${resp[4]}"
    typeset -g  VCS_STATUS_LOCAL_BRANCH="${resp[5]}"
    typeset -g  VCS_STATUS_REMOTE_BRANCH="${resp[6]}"
    typeset -g  VCS_STATUS_REMOTE_NAME="${resp[7]}"
    typeset -g  VCS_STATUS_REMOTE_URL="${resp[8]}"
    typeset -g  VCS_STATUS_ACTION="${resp[9]}"
    typeset -gi VCS_STATUS_HAS_STAGED="${resp[10]}"
    typeset -gi VCS_STATUS_HAS_UNSTAGED="${resp[11]}"
    typeset -gi VCS_STATUS_HAS_UNTRACKED="${resp[12]}"
    typeset -gi VCS_STATUS_COMMITS_AHEAD="${resp[13]}"
    typeset -gi VCS_STATUS_COMMITS_BEHIND="${resp[14]}"
    typeset -gi VCS_STATUS_STASHES="${resp[15]}"
    typeset -g  VCS_STATUS_TAG="${resp[16]}"
  } || {
    (( ours )) && VCS_STATUS_RESULT=norepo-sync || VCS_STATUS_RESULT=norepo-async
    unset VCS_STATUS_WORKDIR
    unset VCS_STATUS_COMMIT
    unset VCS_STATUS_LOCAL_BRANCH
    unset VCS_STATUS_REMOTE_BRANCH
    unset VCS_STATUS_REMOTE_NAME
    unset VCS_STATUS_REMOTE_URL
    unset VCS_STATUS_ACTION
    unset VCS_STATUS_HAS_STAGED
    unset VCS_STATUS_HAS_UNSTAGED
    unset VCS_STATUS_HAS_UNTRACKED
    unset VCS_STATUS_COMMITS_AHEAD
    unset VCS_STATUS_COMMITS_BEHIND
    unset VCS_STATUS_STASHES
    unset VCS_STATUS_TAG
  }

  (( ! ours )) && (( #header )) && emulate -L zsh && "${header[@]}" || true
}

# Starts gitstatusd in the background. Does nothing and succeeds if gitstatusd is already running.
#
# Usage: gitstatus_start [OPTION]... NAME
#
#   -t FLOAT  Fail the self-check on initialization if not getting a response from gitstatusd for
#             this this many seconds. Defaults to 5.
#   -m INT    Report -1 unstaged and untracked if there are more than this many files in the index.
#             Negative value means infinity. Defaults to -1.
function gitstatus_start() {
  emulate -L zsh
  setopt err_return no_unset no_bg_nice

  local opt
  local -F timeout=5
  local -i max_dirty=-1
  while true; do
    getopts "t:m:" opt || break
    case $opt in
      t) timeout=$OPTARG;;
      m) max_dirty=$OPTARG;;
      ?) return 1;;
    esac
  done

  (( timeout > 0 )) || { echo "invalid -t: $timeout" >&2; return 1 }
  (( OPTIND == ARGC )) || { echo "usage: gitstatus_start [OPTION]... NAME" >&2; return 1 }
  local name=${*[$OPTIND]}

  [[ -z ${(P)${:-GITSTATUS_DAEMON_PID_${name}}:-} ]] || return 0

  local dir && dir=${${(%):-%x}:A:h}
  local xtrace_file lock_file req_fifo resp_fifo log_file
  local -i stderr_fd=-1 lock_fd=-1 req_fd=-1 resp_fd=-1 daemon_pid=-1

  function gitstatus_start_impl() {
    [[ ${GITSTATUS_ENABLE_LOGGING:-0} != 1 ]] || {
      xtrace_file=$(mktemp "${TMPDIR:-/tmp}"/gitstatus.$$.xtrace.XXXXXXXXXX)
      typeset -g GITSTATUS_XTRACE_${name}=$xtrace_file
      exec {stderr_fd}>&2 2>$xtrace_file
      setopt xtrace
    }

    local os && os=$(uname -s) && [[ -n $os ]]
    local arch && arch=$(uname -m) && [[ -n $arch ]]

    local daemon=${GITSTATUS_DAEMON:-$dir/bin/gitstatusd-${os:l}-${arch:l}}
    [[ -f $daemon ]]

    lock_file=$(mktemp "${TMPDIR:-/tmp}"/gitstatus.$$.lock.XXXXXXXXXX)
    zsystem flock -f lock_fd $lock_file

    req_fifo=$(mktemp -u "${TMPDIR:-/tmp}"/gitstatus.$$.pipe.req.XXXXXXXXXX)
    mkfifo $req_fifo
    sysopen -rw -o cloexec,sync -u req_fd $req_fifo
    command rm -f $req_fifo

    resp_fifo=$(mktemp -u "${TMPDIR:-/tmp}"/gitstatus.$$.pipe.resp.XXXXXXXXXX)
    mkfifo $resp_fifo
    sysopen -rw -o cloexec -u resp_fd $resp_fifo
    command rm -f $resp_fifo

    function _gitstatus_process_response_${name}() {
      _gitstatus_process_response ${${(%)${:-%N}}#_gitstatus_process_response_} 0 ''
    }
    zle -F $resp_fd _gitstatus_process_response_${name}

    [[ ${GITSTATUS_ENABLE_LOGGING:-0} == 1 ]] &&
      log_file=$(mktemp "${TMPDIR:-/tmp}"/gitstatus.$$.daemon-log.XXXXXXXXXX) ||
      log_file=/dev/null
    typeset -g GITSTATUS_DAEMON_LOG_${name}=$log_file

    local -i threads=${GITSTATUS_NUM_THREADS:-0}
    (( threads > 0)) || {
      case $os in
        FreeBSD) threads=$(( 2 * $(sysctl -n hw.ncpu) ));;
        *) threads=$(( 2 * $(getconf _NPROCESSORS_ONLN) ));;
      esac
      (( threads <= 32 )) || threads=32
    }

    # We use `zsh -c` instead of plain {} or () to work around bugs in zplug. It hangs on startup.
    zsh -dfxc "
      ${(q)daemon}             \
        --lock-fd=3            \
        --parent-pid=$$        \
        --num-threads=$threads \
        --dirty-max-index-size=$max_dirty
      echo -nE $'bye\x1f0\x1e'
    " <&$req_fd >&$resp_fd 2>$log_file 3<$lock_file &!

    daemon_pid=$!
    command rm -f $lock_file

    local reply
    echo -nE $'hello\x1f\x1e' >&$req_fd
    IFS='' read -r -d $'\x1e' -u $resp_fd -t $timeout reply
    [[ $reply == $'hello\x1f0' ]]

    function _gitstatus_cleanup_${ZSH_SUBSHELL}_${daemon_pid}() {
      emulate -L zsh
      setopt err_return no_unset
      local fname=${(%):-%N}
      local prefix=_gitstatus_cleanup_${ZSH_SUBSHELL}_
      [[ $fname == ${prefix}* ]] || return 0
      local -i daemon_pid=${fname#$prefix}
      kill -- -$daemon_pid &>/dev/null || true
    }
    add-zsh-hook zshexit _gitstatus_cleanup_${ZSH_SUBSHELL}_${daemon_pid}

    [[ $stderr_fd == -1 ]] || {
      unsetopt xtrace
      exec 2>&$stderr_fd {stderr_fd}>&-
      stderr_fd=-1
    }
  }

  gitstatus_start_impl && {
    typeset -gi  GITSTATUS_DAEMON_PID_${name}=$daemon_pid
    typeset -gi _GITSTATUS_REQ_FD_${name}=$req_fd
    typeset -gi _GITSTATUS_RESP_FD_${name}=$resp_fd
    typeset -gi _GITSTATUS_LOCK_FD_${name}=$lock_fd
    typeset -gi _GITSTATUS_CLIENT_PID_${name}=$$
    unset -f gitstatus_start_impl
  } || {
    unsetopt err_return
    add-zsh-hook -d zshexit _gitstatus_cleanup_${ZSH_SUBSHELL}_${daemon_pid}
    [[ $daemon_pid -gt 0 ]] && kill -- -$daemon_pid &>/dev/null
    [[ $stderr_fd  -ge 0 ]] && { exec 2>&$stderr_fd {stderr_fd}>&- }
    [[ $lock_fd    -ge 0 ]] && zsystem flock -u $lock_fd
    [[ $req_fd     -ge 0 ]] && exec {req_fd}>&-
    [[ $resp_fd    -ge 0 ]] && { zle -F $resp_fd; exec {resp_fd}>&- }
    command rm -f $lock_file $req_fifo $resp_fifo
    unset -f gitstatus_start_impl

    >&2 print -P '[%F{red}ERROR%f]: gitstatus failed to initialize.'
    >&2 echo -E ''
    >&2 echo -E '  Your git prompt may disappear or become slow.'
    if [[ -s $xtrace_file ]]; then
      >&2 echo -E ''
      >&2 echo -E "  The content of ${(q-)xtrace_file} (gitstatus_start_impl xtrace):"
      >&2 print -P '%F{yellow}'
      >&2 awk '{print "    " $0}' <$xtrace_file
      >&2 print -P '%F{red}                               ^ this command failed%f'
    fi
    if [[ -s $log_file ]]; then
      >&2 echo -E ''
      >&2 echo -E "  The content of ${(q-)log_file} (gitstatus daemon log):"
      >&2 print -P '%F{yellow}'
      >&2 awk '{print "    " $0}' <$log_file
      >&2 print -nP '%f'
    fi
    if [[ ${GITSTATUS_ENABLE_LOGGING:-0} == 1 ]]; then
      >&2 echo -E ''
      >&2 echo -E '  Your system information:'
      >&2 print -P '%F{yellow}'
      >&2 echo -E "    zsh:      $ZSH_VERSION"
      >&2 echo -E "    uname -a: $(uname -a)"
      >&2 print -P '%f'
      >&2 echo -E '  If you need help, open an issue and attach this whole error message to it:'
      >&2 echo -E ''
      >&2 print -P '    %F{green}https://github.com/romkatv/gitstatus/issues/new%f'
    else
      >&2 echo -E ''
      >&2 echo -E '  Run the following command to retry with extra diagnostics:'
      >&2 print -P '%F{green}'
      >&2 echo -E "    GITSTATUS_ENABLE_LOGGING=1 gitstatus_start ${(@q-)*}"
      >&2 print -nP '%f'
    fi

    return 1
  }
}

# Stops gitstatusd if it's running.
#
# Usage: gitstatus_stop NAME.
function gitstatus_stop() {
  emulate -L zsh
  setopt no_unset
  (( ARGC == 1 )) || { echo "usage: gitstatus_stop NAME" >&2; return 1 }

  local name=$1

  local req_fd_var=_GITSTATUS_REQ_FD_${name}
  local resp_fd_var=_GITSTATUS_RESP_FD_${name}
  local lock_fd_var=_GITSTATUS_LOCK_FD_${name}
  local daemon_pid_var=GITSTATUS_DAEMON_PID_${name}
  local client_pid_var=_GITSTATUS_CLIENT_PID_${name}

  local req_fd=${(P)req_fd_var:-}
  local resp_fd=${(P)resp_fd_var:-}
  local lock_fd=${(P)lock_fd_var:-}
  local daemon_pid=${(P)daemon_pid_var:-}

  local cleanup_func=_gitstatus_cleanup_${ZSH_SUBSHELL}_${daemon_pid}

  [[ -n $daemon_pid ]] && kill -- -$daemon_pid &>/dev/null
  [[ -n $req_fd     ]] && exec {req_fd}>&-
  [[ -n $resp_fd    ]] && { zle -F $resp_fd; exec {resp_fd}>&- }
  [[ -n $lock_fd    ]] && zsystem flock -u $lock_fd

  unset $req_fd_var $resp_fd_var $lock_fd_var $daemon_pid_var $client_pid_var

  if (( $+functions[$cleanup_func] )); then
    add-zsh-hook -d zshexit $cleanup_func
    unfunction $cleanup_func
  fi

  return 0
}

# Usage: gitstatus_check NAME.
#
# Returns 0 if and only if `gitstatus_start NAME` has succeeded previously.
# If it returns non-zero, gitstatus_query NAME is guaranteed to return non-zero.
function gitstatus_check() {
  emulate -L zsh
  (( ARGC == 1 )) || { echo "usage: gitstatus_check NAME" >&2; return 1 }
  [[ -n ${(P)${:-GITSTATUS_DAEMON_PID_${1}}} ]]
}
