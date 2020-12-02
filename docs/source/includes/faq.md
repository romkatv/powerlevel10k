# FAQ

## How do I update Powerlevel10k?

The command to update Powerlevel10k depends on how it was installed.

| Installation                             | Update command                                                            |
| ---------------------------------------- | ------------------------------------------------------------------------- |
| [Manual](#manual)         | `git -C ~/powerlevel10k pull`                                             |
| [Oh My Zsh](#oh-my-zsh)   | `git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull` |
| [Prezto](#prezto)         | `zprezto-update`                                                          |
| [Zim](#zim)               | `zimfw update`                                                            |
| [Antigen](#antigen)       | `antigen update`                                                          |
| [Zplug](#zplug)           | `zplug update`                                                            |
| [Zgen](#zgen)             | `zgen update`                                                             |
| [Zplugin](#zplugin)       | `zplugin update`                                                          |
| [Zinit](#zinit)           | `zinit update`                                                            |
| [Homebrew](#homebrew)     | `brew update && brew upgrade`                                             |
| [Arch Linux](#arch-linux) | `yay -S --noconfirm zsh-theme-powerlevel10k-git`                          |

**IMPORTANT**: Restart Zsh after updating Powerlevel10k. [Do not use `source ~/.zshrc`](#weird-things-happen-after-typing-source-zshrc).

## How do I uninstall Powerlevel10k?

Remove all references to "p10k" from `~/.zshrc`. You might have this snippet at the top:

```zsh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
```

And this at the bottom:

```zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

These are added by the [configuration wizard](#configuration-wizard). Remove them.

Remove all references to "powerlevel10k" from `~/.zshrc`, `~/.zpreztorc` and `~/.zimrc` (some
of these files may be missing -- this is normal). These references have been added manually by
yourself when installing Powerlevel10k. Refer to the [installation instructions]()
if you need a reminder.
Verify that all references to "p10k" and "powerlevel10k" are gone from `~/.zshrc`, `~/.zpreztorc`
and `~/.zimrc`.

```zsh
grep -E 'p10k|powerlevel10k' ~/.zshrc ~/.zpreztorc ~/.zimrc 2>/dev/null
```

If this command produces output, there are still references to "p10k" or "powerlevel10k". You
need to remove them.

Delete Powerlevel10k configuration file. This file is created by the
[configuration wizard](#configuration-wizard) and may contain manual edits by yourself.

```zsh
rm -f ~/.p10k.zsh
```

Delete Powerlevel10k source files. These files have been downloaded when you've installed
Powerlevel10k. The command to delete them depends on which installation method you'd chosen.
Refer to the [installation instructions]() if you need a reminder.

| Installation                             | Uninstall command                                                       |
| ---------------------------------------- | ----------------------------------------------------------------------- |
| [Manual](#manual)         | `rm -rf ~/powerlevel10k`                                                |
| [Oh My Zsh](#oh-my-zsh)   | `rm -rf -- ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k` |
| [Prezto](#prezto)         | n/a                                                                     |
| [Zim](#zim)               | `zimfw uninstall`                                                       |
| [Antigen](#antigen)       | `antigen purge romkatv/powerlevel10k`                                   |
| [Zplug](#zplug)           | `zplug clean`                                                           |
| [Zgen](#zgen)             | `zgen reset`                                                            |
| [Zplugin](#zplugin)       | `zplugin delete romkatv/powerlevel10k`                                  |
| [Zinit](#zinit)           | `zinit delete romkatv/powerlevel10k`                                    |
| [Homebrew](#homebrew)     | `brew uninstall powerlevel10k; brew untap romkatv/powerlevel10k`        |
| [Arch Linux](#arch-linux) | `yay -R --noconfirm zsh-theme-powerlevel10k-git`                        |

Restart Zsh. [Do not use `source ~/.zshrc`](#weird-things-happen-after-typing-source-zshrc).

## How do I install Powerlevel10k on a machine without Internet access?

Run this command on the machine without Internet access:

```sh
uname -sm | tr '[A-Z]' '[a-z]'
```

Run these commands on a machine connected to the Internet after replacing the value of `target_uname` with the output of the previous command:

```sh
target_uname="replace this with the output of the previous command"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
GITSTATUS_CACHE_DIR="$HOME"/powerlevel10k/gitstatus/usrbin ~/powerlevel10k/gitstatus/install -f -s "${target_uname% *}" -m "${target_uname#* }"
```

Copy `~/powerlevel10k` from the machine connected to the Internet to the one without Internet access.
Add `source ~/powerlevel10k/powerlevel10k.zsh-theme` to `~/.zshrc` on the machine without Internet access:

```zsh
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
```

If `~/.zshrc` on the machine without Internet access sets `ZSH_THEME`, remove that line.

```zsh
sed -i.bak '/^ZSH_THEME=/d' ~/.zshrc
```

To update, remove `~/powerlevel10k` on both machines and repeat steps 1-3.

## Where can I ask for help and report bugs?

The best way to ask for help and to report bugs is to [open an issue](https://github.com/romkatv/powerlevel10k/issues).

[Gitter](https://gitter.im/powerlevel10k/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
is another option.

If all else fails, email roman.perepelitsa@gmail.com.

If necessary, encrypt your communication with [this PGP key](https://api.github.com/users/romkatv/gpg_keys).

## Which aspects of shell and terminal does Powerlevel10k affect?

Powerlevel10k defines prompt and nothing else. It sets [prompt-related options](http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting), and parameters `PS1` and `RPS1`.

![Prompt Highlight](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/prompt-highlight.png)

Everything within the highlighted areas on the screenshot is produced by Powerlevel10k.
Powerlevel10k has no control over the terminal content or colors outside these areas.

Powerlevel10k does not affect:

- Terminal window/tab title.
- Colors used by `ls`.
- The behavior of `git` command.
- The content and style of <kbd>Tab</kbd> completions.
- Command line colors (syntax highlighting, autosuggestions, etc.).
- Key bindings.
- Aliases.
- Prompt parameters other than `PS1` and `RPS1`.
- Zsh options other than those [related to prompt](http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting).

## I'm using Powerlevel9k with Oh My Zsh. How do I migrate?

1. Run this command:

```zsh
# Add powerlevel10k to the list of Oh My Zsh themes.
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
# Replace ZSH_THEME="powerlevel9k/powerlevel9k" with ZSH_THEME="powerlevel10k/powerlevel10k".
sed -i.bak 's/powerlevel9k/powerlevel10k/g' ~/.zshrc
# Restart Zsh.
exec zsh
```

2. _Optional but highly recommended:_
   1. Install [the recommended font](#recommended-font-meslo-nerd-font-patched-for-powerlevel10k).
   1. Type `p10k configure` and choose your favorite prompt style.

_Related:_

- [Powerlevel9k compatibility.](features/p9k_compatibility.md)
- [Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?](#does-powerlevel10k-always-render-exactly-the-same-prompt-as-powerlevel9k-given-the-same-config)
- [Extra or missing spaces in prompt compared to Powerlevel9k.](#extra-or-missing-spaces-in-prompt-compared-to-powerlevel9k)
- [Configuration wizard.](#configuration-wizard)

## Is it really fast?

Yes.

<script id="asciicast-249531" src="https://asciinema.org/a/249531.js" async></script>

Benchmark results obtained with
[zsh-prompt-benchmark](https://github.com/romkatv/zsh-prompt-benchmark) on an Intel i9-7900X
running Ubuntu 18.04 with the config from the demo.

| Theme               | Prompt Latency |
| ------------------- | -------------: |
| powerlevel9k/master |        1046 ms |
| powerlevel9k/next   |        1005 ms |
| **powerlevel10k**   |     **8.7 ms** |

Powerlevel10k is over 100 times faster than Powerlevel9k in this benchmark.

In fairness, Powerlevel9k has acceptable latency when given a spartan configuration. If all you need
is the current directory without truncation or shortening, Powerlevel9k can render it for you in
17 ms. Powerlevel10k can do the same 30 times faster but it won't matter in practice because 17 ms
is fast enough (the threshold where latency becomes noticeable is around 50 ms). You have to be
careful with Powerlevel9k configuration as it's all too easy to make prompt frustratingly slow.
Powerlevel10k, on the other hand, doesn't require trading latency for utility -- it's virtually
instant with any configuration. It stays well below the 50 ms mark, leaving most of the latency
budget for other plugins you might install.

## How do I enable instant prompt?

See [instant prompt](features/instant_prompt.md) to learn about instant prompt. This section explains how you
can enable it and lists caveats that you should be aware of.

```zsh
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
```

Instant prompt can be enabled either through `p10k configure` or by manually adding the following
code snippet at the top of `~/.zshrc` 👉:

It's important that you copy the lines verbatim. Don't replace `source` with something else, don't
call `zcompile`, don't redirect output, etc.

When instant prompt is enabled, for the duration of Zsh initialization standard input is redirected
to `/dev/null` and standard output with standard error are redirected to a temporary file. Once Zsh
is fully initialized, standard file descriptors are restored and the content of the temporary file
is printed out.

When using instant prompt, you should carefully check any output that appears on Zsh startup as it
may indicate that initialization has been altered, or perhaps even broken, by instant prompt.
Initialization code that may require console input, such as asking for a keyring password or for a
_[y/n]_ confirmation, must be moved above the instant prompt preamble in `~/.zshrc`. Initialization
code that merely prints to console but never reads from it will work correctly with instant prompt,
although output that normally has colors may appear uncolored. You can either leave it be, suppress
the output, or move it above the instant prompt preamble.

```zsh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

keychain id_rsa --agents ssh  # asks for password
chatty-script                 # spams to stdout even when everything is fine
# ...
```

Here's an example of `~/.zshrc` that breaks when instant prompt is enabled 👉:

Fixed version:

```zsh
keychain id_rsa --agents ssh  # moved before instant prompt

# OK to perform console I/O before this point.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# From this point on, until zsh is fully initialized, console input won't work and
# console output may appear uncolored.

chatty-script >/dev/null      # spam output suppressed
# ...
```

If `POWERLEVEL9K_INSTANT_PROMPT` is unset or set to `verbose`, Powerlevel10k will print a warning
when it detects console output during initialization to bring attention to potential issues. You can
silence this warning (without suppressing console output) with `POWERLEVEL9K_INSTANT_PROMPT=quiet`.
This is recommended if some initialization code in `~/.zshrc` prints to console and it's infeasible
to move it above the instant prompt preamble or to suppress its output. You can completely disable
instant prompt with `POWERLEVEL9K_INSTANT_PROMPT=off`. Do this if instant prompt breaks Zsh
initialization and you don't know how to fix it.

_Note_: Instant prompt requires Zsh >= 5.4. It's OK to enable it even when using an older version of
Zsh but it won't do anything.

## What do different symbols in Git status mean?

When using Lean, Classic or Rainbow style, Git status may look like this 👉:

```text
feature:master ⇣42⇡42 ⇠42⇢42 *42 merge ~42 +42 !42 ?42
```

| Symbol    | Meaning                                                              | Source                                                                                  |
| --------- | -------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `feature` | current branch; replaced with `#tag` or `@commit` if not on a branch | `git status --ignore-submodules=dirty`                                                  |
| `master`  | remote tracking branch; only shown if different from local branch    | `git rev-parse --abbrev-ref --symbolic-full-name @{u}`                                  |
| `⇣42`     | this many commits behind the remote                                  | `git status --ignore-submodules=dirty`                                                  |
| `⇡42`     | this many commits ahead of the remote                                | `git status --ignore-submodules=dirty`                                                  |
| `⇠42`     | this many commits behind the push remote                             | `git rev-list --left-right --count HEAD...@{push}`                                      |
| `⇢42`     | this many commits ahead of the push remote                           | `git rev-list --left-right --count HEAD...@{push}`                                      |
| `*42`     | this many stashes                                                    | `git stash list`                                                                        |
| `merge`   | repository state                                                     | `git status --ignore-submodules=dirty`                                                  |
| `~42`     | this many merge conflicts                                            | `git status --ignore-submodules=dirty`                                                  |
| `+42`     | this many staged changes                                             | `git status --ignore-submodules=dirty`                                                  |
| `!42`     | this many unstaged changes                                           | `git status --ignore-submodules=dirty`                                                  |
| `?42`     | this many untracked files                                            | `git status --ignore-submodules=dirty`                                                  |
| `─`       | the number of staged, unstaged or untracked files is unknown         | `echo $POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY` or `git config --get bash.showDirtyState` |

_Related_: [How do I change the format of Git status?](#how-do-i-change-the-format-of-git-status)

## How do I change the format of Git status?

To change the format of Git status, open `~/.p10k.zsh`, search for `my_git_formatter` and edit its
source code.

_Related_: [What do different symbols in Git status mean?](#what-do-different-symbols-in-git-status-mean)

## Why is Git status from `$HOME/.git` not displayed in prompt?

```zsh
# Don't show Git status in prompt for repositories whose workdir matches this pattern.
# For example, if set to '~', the Git repository at $HOME/.git will be ignored.
# Multiple patterns can be combined with '|': '~(|/foo)|/bar/baz/*'.
typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
```

When using Lean, Classic or Rainbow style, `~/.p10k.zsh` contains the following parameter 👉:

To see Git status for `$HOME/.git` in prompt, open `~/.p10k.zsh` and remove
`POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN`.

## Why does Git status sometimes appear grey and then gets colored after a short period of time?

tl;dr: When Git status in prompt is greyed out, it means Powerlevel10k is currently computing
up-to-date Git status in the background. Prompt will get automatically refreshed when this
computation completes.

When your current directory is within a Git repository, Powerlevel10k computes up-to-date Git
status after every command. If the repository is large, or the machine is slow, this computation
can take quite a bit of time. If it takes longer than 20 milliseconds (configurable via
`POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS`), Powerlevel10k displays the last known Git status in
grey and continues to compute up-to-date Git status in the background. When the computation
completes, Powerlevel10k refreshes prompt with new information, this time with colored Git status.

## How do I add username and/or hostname to prompt?

When using Lean, Classic or Rainbow style, prompt shows `username@hostname` when you are logged in
as root or via SSH. There is little value in showing `username` or `hostname` when you are logged in
to your local machine as a normal user. So the absence of `username@hostname` in your prompt is an
indication that you are working locally and that you aren't root. You can change it, however.

```zsh
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  ...
  context  # user@hostname
  ...
)
```

Open `~/.p10k.zsh`. Close to the top you can see the most important parameters that define which
segments are shown in your prompt. All generally useful prompt segments are listed in there. Some of
them are enabled, others are commented out. One of them is of interest to you.

```zsh
# Don't show context unless running with privileges or in SSH.
# Tip: Remove the next line to always show context.
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
```

Search for `context` to find the section in the config that lists parameters specific to this prompt
segment. You should see the following lines 👉:

If you follow the tip and remove (or comment out) the last line, you'll always see
`username@hostname` in prompt. You can change the format to just `username`, or change the color, by
adjusting the values of parameters nearby. There are plenty of comments to help you navigate.

You can also move `context` to a different position in `POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS` or even
to `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS`.

## Why some prompt segments appear and disappear as I'm typing?

Prompt segments can be configured to be shown only when the current command you are typing invokes
a relevant tool.

```zsh
# Show prompt segment "kubecontext" only when the command you are typing
# invokes kubectl, helm, kubens, kubectx, oc, istioctl, kogito, k9s or helmfile.
typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile'
```

Configs created by `p10k configure` may contain parameters of this kind. To customize when different
prompt segments are shown, open `~/.p10k.zsh`, search for `SHOW_ON_COMMAND` and either remove these
parameters or change their values.

You can also define a function in `~/.zshrc` to toggle the display of a prompt segment between
_always_ and _on command_. This is similar to `kubeon`/`kubeoff` from
[kube-ps1](https://github.com/jonmosco/kube-ps1).

```zsh
function kube-toggle() {
  if (( ${+POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND} )); then
    unset POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND
  else
    POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile'
  fi
  p10k reload
  if zle; then
    zle push-input
    zle accept-line
  fi
}
```

Invoke this function by typing `kube-toggle`. You can also bind it to a key by adding two more lines
to `~/.zshrc`:

```zsh
zle -N kube-toggle
bindkey '^]' kube-toggle  # ctrl-] to toggle kubecontext in powerlevel10k prompt
```

## How do I change prompt colors?

You can either [change the color palette used by your terminal](#change-the-color-palette-used-by-your-terminal) or
[set colors through Powerlevel10k configuration parameters](#set-colors-through-powerlevel10k-configuration-parameters).

### Change the color palette used by your terminal

How exactly you change the terminal color palette (a.k.a. color scheme, or theme) depends on the
kind of terminal you are using. Look around in terminal's settings/preferences or consult
documentation.

When you change the terminal color palette, it usually affects only the first 16 colors, numbered
from 0 to 15. In order to see any effect on Powerlevel10k prompt, you need to use prompt style that
utilizes these low-numbered colors. Type `p10k configure` and select _Rainbow_, _Lean_ → _8 colors_
or _Pure_ → _Original_. Other styles use higher-numbered colors, so they look the same in any
terminal color palette.

### Set colors through Powerlevel10k configuration parameters

Open `~/.p10k.zsh`, search for "color", "foreground" and "background" and change values of
appropriate parameters. For example, here's how you can set the foreground of `time` prompt segment
to bright red:

```zsh
typeset -g POWERLEVEL9K_TIME_FOREGROUND=160
```

Colors are specified using numbers from 0 to 255. Colors from 0 to 15 look differently in different
terminals. Many terminals also support customization of these colors through color palettes
(a.k.a. color schemes, or themes). Colors from 16 to 255 always look the same.

Type `source ~/.p10k.zsh` to apply your changes to the current Zsh session.

To see how different colors look in your terminal, run the following command:

```zsh
for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
```

## Why does Powerlevel10k spawn extra processes?

Powerlevel10k uses [gitstatus](https://github.com/romkatv/gitstatus) as the backend behind `vcs`
prompt; gitstatus spawns `gitstatusd` and `zsh`. See
[gitstatus](https://github.com/romkatv/gitstatus) for details. Powerlevel10k may also spawn `zsh`
to perform computation without blocking prompt. To avoid security hazard, these background processes
aren't shared by different interactive shells. They terminate automatically when the parent `zsh`
process terminates or runs `exec(3)`.

## Are there configuration options that make Powerlevel10k slow?

No, Powerlevel10k is always fast, with any configuration you throw at it. If you have noticeable
prompt latency when using Powerlevel10k, please
[open an issue](https://github.com/romkatv/powerlevel10k/issues).

## Is Powerlevel10k fast to load?

Yes, provided that you are using Zsh >= 5.4.

Loading time, or time to first prompt, can be measured with the following benchmark:

```zsh
time (repeat 1000 zsh -dfis <<< 'source ~/powerlevel10k/powerlevel10k.zsh-theme')
```

_Note:_ This measures time to first complete prompt. Powerlevel10k can also display a
[limited prompt](features/instant_prompt.md) before the full-featured prompt is ready.

Running this command with `~/powerlevel10k` as the current directory on the same machine as in the
[prompt benchmark](#is-it-really-fast) takes 29 seconds (29 ms per invocation). This is about 6
times faster than powerlevel9k/master and 17 times faster than powerlevel9k/next.

## What is the relationship between Powerlevel9k and Powerlevel10k?

Powerlevel10k was forked from Powerlevel9k in March 2019 after a week-long discussion in
[powerlevel9k#1170](https://github.com/Powerlevel9k/powerlevel9k/issues/1170). Powerlevel9k was
already a mature project with large user base and release cycle measured in months. Powerlevel10k
was spun off to iterate on performance improvements and new features at much higher pace.

Powerlevel9k and Powerlevel10k are independent projects. When using one, you shouldn't install the
other. Issues should be filed against the project that you actually use. There are no individuals
that have commit rights in both repositories. All bug fixes and new features committed to
Powerlevel9k repository get ported to Powerlevel10k.

Over time, virtually all code in Powerlevel10k has been rewritten. There is currently no meaningful
overlap between the implementations of Powerlevel9k and Powerlevel10k.

Powerlevel10k is committed to maintaining backward compatibility with all configs indefinitely. This
commitment covers all configuration parameters recognized by Powerlevel9k (see
[Powerlevel9k compatibility](features/p9k_compatibility.md)) and additional parameters that only
Powerlevel10k understands. Names of all parameters in Powerlevel10k start with `POWERLEVEL9K_` for
consistency.

## Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?

Almost. There are a few differences.

- By default only `git` vcs backend is enabled in Powerlevel10k. If you need `svn` and `hg`, add
  them to `POWERLEVEL9K_VCS_BACKENDS`. These backends aren't yet optimized in Powerlevel10k, so
  enabling them will make prompt _very slow_.
- Powerlevel10k doesn't support `POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY=true`.
- Powerlevel10k strives to be bug-compatible with Powerlevel9k but not when it comes to egregious
  bugs. If you accidentally rely on these bugs, your prompt will differ between Powerlevel9k and
  Powerlevel10k. Some examples:
  - Powerlevel9k ignores some options that are set after the theme is sourced while Powerlevel10k
    respects all options. If you see different icons in Powerlevel9k and Powerlevel10k, you've
    probably defined `POWERLEVEL9K_MODE` before sourcing the theme. This parameter gets ignored
    by Powerlevel9k but honored by Powerlevel10k. If you want your prompt to look in Powerlevel10k
    the same as in Powerlevel9k, remove `POWERLEVEL9K_MODE`.
  - Powerlevel9k doesn't respect `ZLE_RPROMPT_INDENT`. As a result, right prompt in Powerlevel10k
    can have an extra space at the end compared to Powerlevel9k. Set `ZLE_RPROMPT_INDENT=0` if you
    don't want that space. More details in
    [troubleshooting](#extra-space-without-background-on-the-right-side-of-right-prompt).
  - Powerlevel9k has inconsistent spacing around icons. This was fixed in Powerlevel10k. Set
    `POWERLEVEL9K_LEGACY_ICON_SPACING=true` to get the same spacing as in Powerlevel9k. More
    details in [troubleshooting](#extra-or-missing-spaces-around-icons).
  - There are dozens more bugs in Powerlevel9k that don't exist in Powerlevel10k.

If you notice any other changes in prompt appearance when switching from Powerlevel9k to
Powerlevel10k, please [open an issue](https://github.com/romkatv/powerlevel10k/issues).

## What is the best prompt style in the configuration wizard?

There are as many opinions on what constitutes the best prompt as there are people. It mostly comes
down to personal preference. There are, however, a few hidden implications of different choices.

Pure style is an exact replication of [Pure Zsh theme](https://github.com/sindresorhus/pure). It
exists to ease the migration for users of this theme. Unless you are one of them, choose Lean
style over Pure.

If you want to confine prompt colors to the selected terminal color palette (say, _Solarized Dark_),
use _Rainbow_, _Lean_ → _8 colors_ or _Pure_ → _Original_. Other styles use fixed colors and thus
look the same in any terminal color palette.

All styles except Pure have an option to use _ASCII_ charset. Prompt will look less pretty but will
render correctly with all fonts and in all locales.

If you enable transient prompt, take advantage of two-line prompt. You'll get the benefit of
extra space for typing commands without the usual drawback of reduced scrollback density. Having
all commands start from the same offset is also nice.

Similarly, if you enable transient prompt, sparse prompt (with an empty line before prompt) is a
great choice.

If you are using vi keymap, choose prompt with `prompt_char` in it (shown as green `❯` in the
wizard). This symbol changes depending on vi mode: `❯`, `❮`, `V`, `▶` for insert, command, visual
and replace mode respectively. When a command fails, the symbol turns red. _Lean_ style always has
`prompt_char` in it. _Rainbow_ and _Classic_ styles have it only in the two-line configuration
without left frame.

If you value horizontal space or prefer minimalist aesthetics:

- Use a monospace font, such as [the recommended font](#recommended-font-meslo-nerd-font-patched-for-powerlevel10k).
  Non-monospace fonts require extra space after icons that are larger than a single column.
- Use Lean style. Compared to Classic and Rainbow, it saves two characters per prompt segment.
- Disable _current time_ and _frame_.
- Use _few icons_. The extra icons enabled by the _many icons_ option primarily serve decorative
  function. Informative icons, such as background job indicator, will be shown either way.

_Note_: You can run configuration wizard as many times as you like. Type `p10k configure` to try new
prompt style.

## How to make Powerlevel10k look like robbyrussell Oh My Zsh theme?

Use [this config](https://github.com/romkatv/powerlevel10k/blob/master/config/p10k-robbyrussell.zsh).

You can either download it, save as `~/.p10k.zsh` and `source ~/.p10k.zsh` from `~/.zshrc`, or
source `p10k-robbyrussell.zsh` directly from your cloned `powerlevel10k` repository.

## Can prompts for completed commands display error status for _those_ commands instead of the commands preceding them?

No. When you hit _ENTER_ and the command you've typed starts running, its error status isn't yet
known, so it cannot be shown in prompt. When the command completes, the error status gets known but
it's no longer possible to update prompt for _that_ command. This is why the error status for every
command is reflected in the _next_ prompt.

For details, see [this post on /r/zsh](https://www.reddit.com/r/zsh/comments/eg49ff/powerlevel10k_prompt_history_exit_code_colors/fc5huku).

## What is the minimum supported Zsh version?

Zsh 5.1 or newer should work. Fast startup requires Zsh >= 5.4.

## How were these screenshots and animated gifs created?

All screenshots and animated gifs were recorded in GNOME Terminal with
[the recommended font](#recommended-font-meslo-nerd-font-patched-for-powerlevel10k) and Tango Dark color palette with
custom background color (`#171A1B` instead of `#2E3436` -- twice as dark).

![GNOME Terminal Color Settings](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/gnome-terminal-colors.png)

Syntax highlighting, where present, was provided by [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting).

## How was the recommended font created?

[The recommended font](#recommended-font-meslo-nerd-font-patched-for-powerlevel10k) is the product of many
individuals. Its origin is _Bitstream Vera Sans Mono_, which has given birth to _Menlo_, which in
turn has spawned _Meslo_. Finally, extra glyphs have been added to _Meslo_ with scripts forked
from Nerd Fonts. The final font is released under the terms of
[Apache License](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20License.txt).

```zsh
git clone --depth=1 https://github.com/romkatv/nerd-fonts.git
cd nerd-fonts
./build 'Meslo/S/*'
```

MesloLGS NF font can be recreated with the following command (requires `git` and `docker`) 👉:

If everything goes well, four `ttf` files will appear in `./out`.

## How to package Powerlevel10k for distribution?

It's currently neither easy nor recommended to package and distribute Powerlevel10k. There are no
instructions you can follow that would allow you to easily update your package when new versions of
Powerlevel10k are released. This may change in the future but not soon.
