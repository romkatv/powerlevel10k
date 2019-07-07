# Powerlevel10k Extended Configuration

Powerlevel10k has configuration options that Powerlevel9k doesn't. These options have `POWERLEVEL9K`
prefix just like the rest.

`POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS (FLOAT) [default=0.05]`

If it takes longer than this to fetch git repo status, display the prompt with a greyed out
vcs segment and fix it asynchronously when the results come it.

`POWERLEVEL9K_VCS_BACKENDS (ARRAY) [default=(git)]`

The list of VCS backends to use. Supported values are `git`, `svn` and `hg`. Note that adding
anything other than git will make prompt slower even when your current directory isn't a repo.

`POWERLEVEL9K_GITSTATUS_DIR (STRING) [default=$POWERLEVEL9K_INSTALLATION_DIR/gitstatus]`

Directory with gitstatus plugin. By default uses a copy bundled with Powerlevel10k.

`POWERLEVEL9K_DISABLE_GITSTATUS (STRING) [default="false"]`

If set to `"true"`, Powerlevel10k won't use its fast git backend and will fall back to
`vcs_info` like Powerlevel9k.

`POWERLEVEL9K_MAX_CACHE_SIZE (INT) [default=10000]`

The maximum number of elements that can be stored in the cache. When the cache grows over this
limit, it gets cleared.

`POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY (INT) [default=-1]`

Don't scan for dirty files in git repos with more files in the index than this. Instead, show
them with the "dirty" color (yellow by default) whether they are dirty or not. This makes git
prompt much faster on huge repositories.

`POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME (STRING) [default="false"]`

If set to `"true"`, `time` segment will update every second, turning into a realtime clock.
This option triggers a
[bug in completion menu](https://www.zsh.org/mla/workers//2019/msg00161.html) in zsh, and
another
[bug in history](https://github.com/bhilburn/powerlevel9k/commit/fb1ef540228ec7b4394cf2f6860137074c5838a6#commitcomment-32779672).
You can pick up a fix for the latter from
[a fork of zsh](https://github.com/romkatv/zsh/tree/gentle-reset-prompt).

When using gitstatus, there is an extra state called `LOADING` that is used by `vcs` prompt
segment when it's waiting for git status in the background. You can define styling for this
state the same way as for the other states -- `CLEAN`, `UNTRACKED` and `MODIFIED`. You can
also define the icon and the text that will be used when `LOADING` state is triggered for a
git repository for which no prior status is known. If both `POWERLEVEL9K_VCS_LOADING_ICON`
and `POWERLEVEL9K_VCS_LOADING_TEXT` are empty, `vcs` segment in such cases won't be shown.

  * `POWERLEVEL9K_VCS_LOADING_ICON (STRING) [default=""]`

    Icon shown while waiting for git status for a repo for the first time.
  * `POWERLEVEL9K_VCS_LOADING_TEXT (STRING) [default="loading"]`

    Text shown while waiting for git status for a repo for the first time.
  * `POWERLEVEL9K_VCS_LOADING_BACKGROUND (STRING) [default="grey"]`

    Background color for `LOADING` state.
  * `POWERLEVEL9K_VCS_LOADING_FOREGROUND (STRING) [default="$DEFAULT_COLOR"]`

    Foreground color for `LOADING` state.
  * `POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR (STRING) [default=$POWERLEVEL9K_VCS_LOADING_FOREGROUND]`

    Foreground color for `POWERLEVEL9K_VCS_LOADING_ICON`.

When using gitstatus, components of `vcs` segment can be colored individually by setting
`POWERLEVEL9K_VCS_${STATE}_${COMPONENT}FORMAT_FOREGROUND`. `${STATE}` should be one of `CLEAN`,
`UNTRACKED`, `MODIFIED` or `LOADING`. `${COMPONENT}` should be one of `REMOTE_URL`, `COMMIT`,
`BRANCH`, `TAG`, `REMOTE_BRANCH`, `STAGED`, `UNSTAGED`, `UNTRACKED`, `OUTGOING_CHANGES`,
`INCOMING_CHANGES`, `STASH` or `ACTION`. If
`POWERLEVEL9K_VCS_${STATE}_${COMPONENT}FORMAT_FOREGROUND` isn't set for some combination of
`${STATE}` and `${COMPONENT}`, the component is colored with
`POWERLEVEL9K_VCS_${COMPONENT}FORMAT_FOREGROUND`. If that one isn't set either, the component is
colored with `POWERLEVEL9K_VCS_${STATE}_FOREGROUND`. The fallback logic is consistent with
Powerlevel9k, meaning that your `vcs` prompt will look the same in Powerlevel10k and
Powerlevel9k if you don't define any `POWERLEVEL9K_VCS_${STATE}_${COMPONENT}_FOREGROUND`
parameters. Note that both the icon and the text in each component always have the same color.
There is currently no `POWERLEVEL9K_VCS_${STATE}_${COMPONENT}FORMAT_VISUAL_IDENTIFIER_COLOR`,
although it's easy to implement if desired.
