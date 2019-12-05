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
#   source ~/gitstatus/gitstatus.plugin.zsh
#   gitstatus_start MY
#   gitstatus_query -d $PWD MY
#   typeset -m 'VCS_STATUS_*'
#
# Output:
#
#   VCS_STATUS_ACTION=''
#   VCS_STATUS_COMMIT=c000eddcff0fb38df2d0137efe24d9d2d900f209
#   VCS_STATUS_COMMITS_AHEAD=0
#   VCS_STATUS_COMMITS_BEHIND=0
#   VCS_STATUS_HAS_CONFLICTED=0
#   VCS_STATUS_HAS_STAGED=0
#   VCS_STATUS_HAS_UNSTAGED=1
#   VCS_STATUS_HAS_UNTRACKED=1
#   VCS_STATUS_INDEX_SIZE=33
#   VCS_STATUS_LOCAL_BRANCH=master
#   VCS_STATUS_NUM_CONFLICTED=0
#   VCS_STATUS_NUM_STAGED=0
#   VCS_STATUS_NUM_UNSTAGED=1
#   VCS_STATUS_NUM_STAGED_NEW=0
#   VCS_STATUS_NUM_STAGED_DELETED=0
#   VCS_STATUS_NUM_UNSTAGED_DELETED=0
#   VCS_STATUS_NUM_UNTRACKED=1
#   VCS_STATUS_REMOTE_BRANCH=master
#   VCS_STATUS_REMOTE_NAME=origin
#   VCS_STATUS_REMOTE_URL=git@github.com:romkatv/powerlevel10k.git
#   VCS_STATUS_RESULT=ok-sync
#   VCS_STATUS_STASHES=0
#   VCS_STATUS_TAG=''
#   VCS_STATUS_WORKDIR=/home/romka/powerlevel10k

[[ -o 'interactive' ]] || 'return'

# Temporarily change options.
'builtin' 'local' '-a' '_gitstatus_opts'
[[ ! -o 'aliases'         ]] || _gitstatus_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || _gitstatus_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || _gitstatus_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

autoload -Uz add-zsh-hook
zmodload zsh/datetime zsh/system

typeset -g _gitstatus_plugin_dir=${${(%):-%x}:A:h}

# Retrives status of a git repo from a directory under its working tree.
#
## Usage: gitstatus_query [OPTION]... NAME
#
#   -d STR    Directory to query. Defaults to the current directory. Has no effect if GIT_DIR
#             is set.
#   -c STR    Callback function to call once the results are available. Called only after
#             gitstatus_query returns 0 with VCS_STATUS_RESULT=tout.
#   -t FLOAT  Timeout in seconds. Will block for at most this long. If no results are
#             available by then: if -c isn't specified, will return 1; otherwise will set
#             VCS_STATUS_RESULT=tout and return 0.
#   -p        Don't compute anything that requires reading Git index. If this option is used,
#             the following parameters will be 0: VCS_STATUS_INDEX_SIZE,
#             VCS_STATUS_{NUM,HAS}_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED}.
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
#   VCS_STATUS_WORKDIR              Git repo working directory. Not empty.
#   VCS_STATUS_COMMIT               Commit hash that HEAD is pointing to. Either 40 hex digits or
#                                   empty if there is no HEAD (empty repo).
#   VCS_STATUS_LOCAL_BRANCH         Local branch name or empty if not on a branch.
#   VCS_STATUS_REMOTE_NAME          The remote name, e.g. "upstream" or "origin".
#   VCS_STATUS_REMOTE_BRANCH        Upstream branch name. Can be empty.
#   VCS_STATUS_REMOTE_URL           Remote URL. Can be empty.
#   VCS_STATUS_ACTION               Repository state, A.K.A. action. Can be empty.
#   VCS_STATUS_INDEX_SIZE           The number of files in the index.
#   VCS_STATUS_NUM_STAGED           The number of staged changes.
#   VCS_STATUS_NUM_CONFLICTED       The number of conflicted changes.
#   VCS_STATUS_NUM_UNSTAGED         The number of unstaged changes.
#   VCS_STATUS_NUM_UNTRACKED        The number of untracked files.
#   VCS_STATUS_HAS_STAGED           1 if there are staged changes, 0 otherwise.
#   VCS_STATUS_HAS_CONFLICTED       1 if there are conflicted changes, 0 otherwise.
#   VCS_STATUS_HAS_UNSTAGED         1 if there are unstaged changes, 0 if there aren't, -1 if
#                                   unknown.
#   VCS_STATUS_NUM_STAGED_NEW       The number of staged new files. Note that renamed files
#                                   are reported as deleted plus new.
#   VCS_STATUS_NUM_STAGED_DELETED   The number of staged deleted files. Note that renamed files
#                                   are reported as deleted plus new.
#   VCS_STATUS_NUM_UNSTAGED_DELETED The number of unstaged deleted files. Note that renamed files
#                                   are reported as deleted plus new.
#   VCS_STATUS_HAS_UNTRACKED        1 if there are untracked files, 0 if there aren't, -1 if
#                                   unknown.
#   VCS_STATUS_COMMITS_AHEAD        Number of commits the current branch is ahead of upstream.
#                                   Non-negative integer.
#   VCS_STATUS_COMMITS_BEHIND       Number of commits the current branch is behind upstream.
#                                   Non-negative integer.
#   VCS_STATUS_STASHES              Number of stashes. Non-negative integer.
#   VCS_STATUS_TAG                  The last tag (in lexicographical order) that points to the same
#                                   commit as HEAD.
#
# The point of reporting -1 via VCS_STATUS_HAS_* is to allow the command to skip scanning files in
# large repos. See -m flag of gitstatus_start.
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
  local dir
  local callback
  local -F timeout=-1
  local no_diff=0
  while true; do
    getopts "d:c:t:p" opt || break
    case $opt in
      d) dir=$OPTARG;;
      c) callback=$OPTARG;;
      t) timeout=$OPTARG;;
      p) no_diff=1;;
      ?) return 1;;
      done) break;;
    esac
  done
  (( OPTIND == ARGC )) || { echo "usage: gitstatus_query [OPTION]... NAME" >&2; return 1 }
  local name=${*[$OPTIND]}

  local daemon_pid_var=GITSTATUS_DAEMON_PID_${name}
  (( ${(P)daemon_pid_var:-0} > 0 ))

  # Verify that gitstatus_query is running in the same process that ran gitstatus_start.
  local client_pid_var=_GITSTATUS_CLIENT_PID_${name}
  [[ ${(P)client_pid_var} == $$ ]]

  [[ -z ${GIT_DIR:-} ]] && {
    [[ $dir == /* ]] || dir=${(%):-%/}/$dir
  } || {
    [[ $GIT_DIR == /* ]] && dir=:$GIT_DIR || dir=:${(%):-%/}/$GIT_DIR
  }

  local req_fd_var=_GITSTATUS_REQ_FD_${name}
  local -i req_fd=${(P)req_fd_var}
  local -r req_id="$EPOCHREALTIME"
  echo -nE $req_id' '$callback$'\x1f'$dir$'\x1f'$no_diff$'\x1e' >&$req_fd

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
  local -i dirty_max_index_size=_GITSTATUS_DIRTY_MAX_INDEX_SIZE_${name}

  typeset -g VCS_STATUS_RESULT
  (( timeout >= 0 )) && local -a t=(-t $timeout) || local -a t=()
  local -a resp
  local IFS=$'\x1f'
  read -rd $'\x1e' -u ${(P)resp_fd_var} $t -A resp || {
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
    typeset -gi VCS_STATUS_INDEX_SIZE="${resp[10]}"
    typeset -gi VCS_STATUS_NUM_STAGED="${resp[11]}"
    typeset -gi VCS_STATUS_NUM_UNSTAGED="${resp[12]}"
    typeset -gi VCS_STATUS_NUM_CONFLICTED="${resp[13]}"
    typeset -gi VCS_STATUS_NUM_UNTRACKED="${resp[14]}"
    typeset -gi VCS_STATUS_COMMITS_AHEAD="${resp[15]}"
    typeset -gi VCS_STATUS_COMMITS_BEHIND="${resp[16]}"
    typeset -gi VCS_STATUS_STASHES="${resp[17]}"
    typeset -g  VCS_STATUS_TAG="${resp[18]}"
    typeset -gi VCS_STATUS_NUM_UNSTAGED_DELETED="${resp[19]}"
    typeset -gi VCS_STATUS_NUM_STAGED_NEW="${resp[20]:-0}"
    typeset -gi VCS_STATUS_NUM_STAGED_DELETED="${resp[21]:-0}"
    typeset -gi VCS_STATUS_HAS_STAGED=$((VCS_STATUS_NUM_STAGED > 0))
    (( dirty_max_index_size >= 0 && VCS_STATUS_INDEX_SIZE > dirty_max_index_size )) && {
      typeset -gi VCS_STATUS_HAS_UNSTAGED=-1
      typeset -gi VCS_STATUS_HAS_CONFLICTED=-1
      typeset -gi VCS_STATUS_HAS_UNTRACKED=-1
    } || {
      typeset -gi VCS_STATUS_HAS_UNSTAGED=$((VCS_STATUS_NUM_UNSTAGED > 0))
      typeset -gi VCS_STATUS_HAS_CONFLICTED=$((VCS_STATUS_NUM_CONFLICTED > 0))
      typeset -gi VCS_STATUS_HAS_UNTRACKED=$((VCS_STATUS_NUM_UNTRACKED > 0))
    }
  } || {
    (( ours )) && VCS_STATUS_RESULT=norepo-sync || VCS_STATUS_RESULT=norepo-async
    unset VCS_STATUS_WORKDIR
    unset VCS_STATUS_COMMIT
    unset VCS_STATUS_LOCAL_BRANCH
    unset VCS_STATUS_REMOTE_BRANCH
    unset VCS_STATUS_REMOTE_NAME
    unset VCS_STATUS_REMOTE_URL
    unset VCS_STATUS_ACTION
    unset VCS_STATUS_INDEX_SIZE
    unset VCS_STATUS_NUM_STAGED
    unset VCS_STATUS_NUM_UNSTAGED
    unset VCS_STATUS_NUM_CONFLICTED
    unset VCS_STATUS_NUM_UNTRACKED
    unset VCS_STATUS_HAS_STAGED
    unset VCS_STATUS_HAS_UNSTAGED
    unset VCS_STATUS_HAS_CONFLICTED
    unset VCS_STATUS_HAS_UNTRACKED
    unset VCS_STATUS_COMMITS_AHEAD
    unset VCS_STATUS_COMMITS_BEHIND
    unset VCS_STATUS_STASHES
    unset VCS_STATUS_TAG
    unset VCS_STATUS_NUM_UNSTAGED_DELETED
    unset VCS_STATUS_NUM_STAGED_NEW
    unset VCS_STATUS_NUM_STAGED_DELETED
  }

  (( ! ours )) && (( #header )) && emulate -L zsh && "${header[@]}" || true
}

# Starts gitstatusd in the background. Does nothing and succeeds if gitstatusd is already running.
#
# Usage: gitstatus_start [OPTION]... NAME
#
#   -t FLOAT  Fail the self-check on initialization if not getting a response from gitstatusd for
#             this this many seconds. Defaults to 5.
#
#   -s INT    Report at most this many staged changes; negative value means infinity.
#             Defaults to 1.
#
#   -u INT    Report at most this many unstaged changes; negative value means infinity.
#             Defaults to 1.
#
#   -c INT    Report at most this many conflicted changes; negative value means infinity.
#             Defaults to 1.
#
#   -d INT    Report at most this many untracked files; negative value means infinity.
#             Defaults to 1.
#
#   -m INT    Report -1 unstaged, untracked and conflicted if there are more than this many
#             files in the index. Negative value means infinity. Defaults to -1.
#
#   -e        Count files within untracked directories like `git status --untracked-files`.
#
#   -U        Unless this option is specified, report zero untracked files for repositories
#             with status.showUntrackedFiles = false.
#
#   -W        Unless this option is specified, report zero untracked files for repositories
#             with bash.showUntrackedFiles = false.
#
#   -D        Unless this option is specified, report zero staged, unstaged and conflicted
#             changes for repositories with bash.showDirtyState = false.
function gitstatus_start() {
  emulate -L zsh
  setopt err_return no_unset no_bg_nice

  local opt
  local -F timeout=5
  local -i max_num_staged=1
  local -i max_num_unstaged=1
  local -i max_num_conflicted=1
  local -i max_num_untracked=1
  local -i dirty_max_index_size=-1
  local -i async
  local -a extra_flags=()
  while true; do
    getopts "t:s:u:c:d:m:eaUWD" opt || break
    case $opt in
      a) async=1;;
      t) timeout=$OPTARG;;
      s) max_num_staged=$OPTARG;;
      u) max_num_unstaged=$OPTARG;;
      c) max_num_conflicted=$OPTARG;;
      d) max_num_untracked=$OPTARG;;
      m) dirty_max_index_size=$OPTARG;;
      e) extra_flags+='--recurse-untracked-dirs';;
      +e) extra_flags=(${(@)extra_flags:#--recurse-untracked-dirs});;
      U) extra_flags+='--ignore-status-show-untracked-files';;
      +U) extra_flags=(${(@)extra_flags:#--ignore-status-show-untracked-files});;
      W) extra_flags+='--ignore-bash-show-untracked-files';;
      +W) extra_flags=(${(@)extra_flags:#--ignore-bash-show-untracked-files});;
      D) extra_flags+='--ignore-bash-show-dirty-state';;
      +D) extra_flags=(${(@)extra_flags:#--ignore-bash-show-dirty-state});;
      ?) return 1;;
    esac
  done

  (( timeout > 0 )) || { echo "invalid -t: $timeout" >&2; return 1 }
  (( OPTIND == ARGC )) || { echo "usage: gitstatus_start [OPTION]... NAME" >&2; return 1 }
  local name=${*[$OPTIND]}

  local lock_file req_fifo resp_fifo log_level
  local log_file=/dev/null xtrace_file=/dev/null
  local -i stderr_fd lock_fd req_fd resp_fd daemon_pid
  local daemon_pid_var=GITSTATUS_DAEMON_PID_${name}
  (( $+parameters[$daemon_pid_var] )) && {
    (( ! async )) || return 0
    daemon_pid=${(P)daemon_pid_var}
    (( daemon_pid == -1 )) || return 0
    local resp_fd_var=_GITSTATUS_RESP_FD_${name}
    local log_file_var=GITSTATUS_DAEMON_LOG_${name}
    local xtrace_file_var=GITSTATUS_XTRACE_${name}
    resp_fd=${(P)resp_fd_var}
    log_file=${(P)log_file_var}
    xtrace_file=${(P)xtrace_file_var}
  } || {
    log_level=${GITSTATUS_LOG_LEVEL:-}
    [[ -n $log_level || ${GITSTATUS_ENABLE_LOGGING:-0} != 1 ]] || log_level=INFO
    [[ -z $log_level ]] || {
      log_file=${TMPDIR:-/tmp}/gitstatus.$$.daemon-log.$EPOCHREALTIME.$RANDOM
      xtrace_file=${TMPDIR:-/tmp}/gitstatus.$$.xtrace.$EPOCHREALTIME.$RANDOM
    }
    typeset -g GITSTATUS_DAEMON_LOG_${name}=$log_file
    typeset -g GITSTATUS_XTRACE_${name}=$xtrace_file
  }

  function gitstatus_start_impl() {
    [[ $xtrace_file == /dev/null ]] || {
      exec {stderr_fd}>&2 2>>$xtrace_file
      setopt xtrace
    }

    (( daemon_pid == -1 )) || {
      local daemon=${GITSTATUS_DAEMON:-} os
      [[ -n $daemon ]] || {
        os="$(uname -s)" && [[ -n $os ]]
        [[ $os != Linux || "$(uname -o)" != Android ]] || os=Android
        [[ ${(L)os} != (mingw|msys)* ]]                || os=MSYS_NT-10.0
        local arch && arch="$(uname -m)" && [[ -n $arch ]]
        daemon=$_gitstatus_plugin_dir/bin/gitstatusd-${os:l}-${arch:l}
      }
      [[ -x $daemon ]]

      lock_file=${TMPDIR:-/tmp}/gitstatus.$$.lock.$EPOCHREALTIME.$RANDOM
      echo -n >$lock_file
      zsystem flock -f lock_fd $lock_file

      req_fifo=${TMPDIR:-/tmp}/gitstatus.$$.req.$EPOCHREALTIME.$RANDOM
      resp_fifo=${TMPDIR:-/tmp}/gitstatus.$$.resp.$EPOCHREALTIME.$RANDOM
      mkfifo $req_fifo $resp_fifo

      local -i threads=${GITSTATUS_NUM_THREADS:-0}
      (( threads > 0)) || {
        threads=8
        [[ -n $os ]] || { os="$(uname -s)" && [[ -n $os ]] }
        case $os in
          FreeBSD) (( ! $+commands[sysctl] )) || threads=$(( 2 * $(sysctl -n hw.ncpu) ));;
          *) (( ! $+commands[getconf] )) || threads=$(( 2 * $(getconf _NPROCESSORS_ONLN) ));;
        esac
        (( threads <= 32 )) || threads=32
      }

      local -a daemon_args=(
        --lock-fd=3
        --parent-pid=${(q)$}
        --num-threads=${(q)threads}
        --max-num-staged=${(q)max_num_staged}
        --max-num-unstaged=${(q)max_num_unstaged}
        --max-num-conflicted=${(q)max_num_conflicted}
        --max-num-untracked=${(q)max_num_untracked}
        --dirty-max-index-size=${(q)dirty_max_index_size}
        --log-level=${(q)log_level:-INFO}
        $extra_flags)

      local cmd="
        exec >&4
        echo \$\$
        ${(q)daemon} $daemon_args
        if [[ \$? != (0|10) && \$? -le 128 && -f ${(q)daemon}-static ]]; then
          ${(q)daemon}-static $daemon_args
        fi
        echo -nE $'bye\x1f0\x1e'"
      local setsid=${commands[setsid]:-/usr/local/opt/util-linux/bin/setsid}
      [[ -x $setsid ]] && setsid=${(q)setsid} || setsid=
      # Try to use the same executable as the current zsh. Some people like having an ancient
      # `zsh` in their PATH while using a newer version. zsh 5.0.2 hangs when enabling `monitor`.
      #
      #   zsh -mc '' &!  # hangs when using zsh 5.0.2
      local zsh=${${:-/proc/self/exe}:A}
      [[ -x $zsh ]] || zsh=zsh
      cmd="cd /; read; $setsid ${(q)zsh} -dfxc ${(q)cmd} &!; rm -f ${(q)req_fifo} ${(q)resp_fifo} ${(q)lock_file}"
      # We use `zsh -c` instead of plain {} or () to work around bugs in zplug (it hangs on
      # startup). Double fork is to daemonize, and so is `setsid`. Note that on macOS `setsid` has
      # to be installed manually by running  `brew install util-linux`.
      $zsh -dfmxc $cmd <$req_fifo >$log_file 2>&1 3<$lock_file 4>$resp_fifo &!

      sysopen -w -o cloexec,sync -u req_fd $req_fifo
      sysopen -r -o cloexec -u resp_fd $resp_fifo
      echo -nE $'0\nhello\x1f\x1e' >&$req_fd
    }

    (( async )) && {
      daemon_pid=-1
    } || {
      local reply IFS=''
      read -ru $resp_fd reply
      [[ $reply == <1-> ]]
      daemon_pid=reply

      function _gitstatus_process_response_${name}() {
        local name=${${(%):-%N}#_gitstatus_process_response_}
        (( ARGC == 1 )) && {
          _gitstatus_process_response $name 0 ''
          true
        } || {
          gitstatus_stop $name
        }
      }
      zle -F $resp_fd _gitstatus_process_response_${name}

      read -r -d $'\x1e' -u $resp_fd -t $timeout reply
      [[ $reply == $'hello\x1f0' ]]

      function _gitstatus_cleanup_$$_${ZSH_SUBSHELL}_${daemon_pid}() {
        emulate -L zsh
        setopt err_return no_unset
        local fname=${(%):-%N}
        local prefix=_gitstatus_cleanup_$$_${ZSH_SUBSHELL}_
        [[ $fname == ${prefix}* ]] || return 0
        local -i daemon_pid=${fname#$prefix}
        kill -- -$daemon_pid &>/dev/null || true
      }
      add-zsh-hook zshexit _gitstatus_cleanup_$$_${ZSH_SUBSHELL}_${daemon_pid}
    }

    (( ! stderr_fd )) || {
      unsetopt xtrace
      exec 2>&$stderr_fd {stderr_fd}>&-
      stderr_fd=0
    }
  }

  gitstatus_start_impl && {
    typeset -gi  GITSTATUS_DAEMON_PID_${name}=$daemon_pid
    (( ! req_fd )) || {
      typeset -gi _GITSTATUS_REQ_FD_${name}=$req_fd
      typeset -gi _GITSTATUS_RESP_FD_${name}=$resp_fd
      typeset -gi _GITSTATUS_LOCK_FD_${name}=$lock_fd
      typeset -gi _GITSTATUS_CLIENT_PID_${name}=$$
      typeset -gi _GITSTATUS_DIRTY_MAX_INDEX_SIZE_${name}=$dirty_max_index_size
    }
    unset -f gitstatus_start_impl
  } || {
    unsetopt err_return
    add-zsh-hook -d zshexit _gitstatus_cleanup_$$_${ZSH_SUBSHELL}_${daemon_pid}
    (( $+functions[_gitstatus_process_response_${name}] )) && {
      zle -F $resp_fd
      unfunction _gitstatus_process_response_${name}
    }
    (( resp_fd        )) && exec {resp_fd}>&-
    (( req_fd         )) && exec {req_fd}>&-
    (( lock_fd        )) && zsystem flock -u $lock_fd
    (( stderr_fd      )) && { exec 2>&$stderr_fd {stderr_fd}>&- }
    (( daemon_pid > 0 )) && kill -- -$daemon_pid &>/dev/null

    rm -f $lock_file $req_fifo $resp_fifo
    unset -f gitstatus_start_impl

    unset GITSTATUS_DAEMON_PID_${name}
    unset _GITSTATUS_REQ_FD_${name}
    unset _GITSTATUS_RESP_FD_${name}
    unset _GITSTATUS_LOCK_FD_${name}
    unset _GITSTATUS_CLIENT_PID_${name}
    unset _GITSTATUS_DIRTY_MAX_INDEX_SIZE_${name}

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
    if [[ ${GITSTATUS_LOG_LEVEL:-} == DEBUG ]]; then
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
      >&2 echo -E "    GITSTATUS_LOG_LEVEL=DEBUG gitstatus_start ${(@q-)*}"
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
  local dirty_size_var=_GITSTATUS_DIRTY_MAX_INDEX_SIZE_${name}

  [[ ${(P)daemon_pid_var:-} != -1 ]] || gitstatus_start -t 0 "$name" 2>/dev/null

  local req_fd=${(P)req_fd_var:-}
  local resp_fd=${(P)resp_fd_var:-}
  local lock_fd=${(P)lock_fd_var:-}
  local daemon_pid=${(P)daemon_pid_var:-0}

  local cleanup_func=_gitstatus_cleanup_$$_${ZSH_SUBSHELL}_${daemon_pid}

  (( $+functions[_gitstatus_process_response_${name}] )) && {
    zle -F $resp_fd
    unfunction _gitstatus_process_response_${name}
  }

  (( resp_fd        )) && exec {resp_fd}>&-
  (( req_fd         )) && exec {req_fd}>&-
  (( lock_fd        )) && zsystem flock -u $lock_fd
  (( daemon_pid > 0 )) && kill -- -$daemon_pid &>/dev/null

  unset $req_fd_var $resp_fd_var $lock_fd_var $daemon_pid_var $client_pid_var $dirty_size_var

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
  local daemon_pid_var=GITSTATUS_DAEMON_PID_${1}
  (( ${(P)daemon_pid_var:-0} > 0 ))
}

(( ${#_gitstatus_opts} )) && setopt ${_gitstatus_opts[@]}
'builtin' 'unset' '_gitstatus_opts'
