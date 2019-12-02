# Powerlevel10k

Powerlevel10k is a theme for ZSH. It's fast, flexible and easy to install and configure.

Powerlevel10k can be used as a [fast](#is-it-really-fast) drop-in replacement for
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k). When given the same configuration options
it will generate the same prompt.

![Powerlevel10k](https://raw.githubusercontent.com/romkatv/powerlevel10k/master/powerlevel10k.png)

## Table of Contents

1. [Installation](#installation)
   1. [Manual](#manual)
   1. [Oh My Zsh](#oh-my-zsh)
   1. [Prezto](#prezto)
   1. [Antigen](#antigen)
   1. [Zplug](#zplug)
   1. [Zgen](#zgen)
   1. [Antibody](#antibody)
   1. [Zplugin](#zplugin)
1. [Configuration](#configuration)
   1. [For new users](#for-new-users)
   1. [For Powerlevel9k users](#for-powerlevel9k-users)
1. [Fonts](#fonts)
   1. [Recommended: Meslo Nerd Font patched for Powerlevel10k](#recommended-meslo-nerd-font-patched-for-powerlevel10k)
1. [Try it in Docker](#try-it-in-docker)
1. [Is it really fast?](#is-it-really-fast)
1. [License](#license)
1. [FAQ](#faq)
   1. [What is instant prompt?](#what-is-instant-prompt)
   1. [Why do my icons and/or powerline symbols look bad?](#why-do-my-icons-andor-powerline-symbols-look-bad)
   1. [I'm getting "character not in range" error. What gives?](#im-getting-character-not-in-range-error-what-gives)
   1. [Why is my cursor in the wrong place?](#why-is-my-cursor-in-the-wrong-place)
   1. [Why is my prompt wrapping around in a weird way?](#why-is-my-prompt-wrapping-around-in-a-weird-way)
   1. [Why is my right prompt in the wrong place?](#why-is-my-right-prompt-in-the-wrong-place)
   1. [I cannot install the recommended font. Help!](#i-cannot-install-the-recommended-font-help)
   1. [Why do I have a question mark symbol in my prompt? Is my font broken?](#why-do-i-have-a-question-mark-symbol-in-my-prompt-is-my-font-broken)
   1. [What do different symbols in Git status mean?](#what-do-different-symbols-in-git-status-mean)
   1. [How do I change the format of Git status?](#how-do-i-change-the-format-of-git-status)
   1. [How do I add username and/or hostname to prompt?](#how-do-i-add-username-andor-hostname-to-prompt)
   1. [Why does Powerlevel10k spawn extra processes?](#why-does-powerlevel10k-spawn-extra-processes)
   1. [Are there configuration options that make Powerlevel10k slow?](#are-there-configuration-options-that-make-powerlevel10k-slow)
   1. [Is Powerlevel10k fast to load?](#is-powerlevel10k-fast-to-load)
   1. [Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?](#does-powerlevel10k-always-render-exactly-the-same-prompt-as-powerlevel9k-given-the-same-config)
   1. [Is there an AUR package for Powerlevel10k?](#is-there-an-aur-package-for-powerlevel10k)
   1. [I cannot make Powerlevel10k work with my plugin manager. Help!](#i-cannot-make-powerlevel10k-work-with-my-plugin-manager-help)
   1. [What is the minimum supported zsh version?](#what-is-the-minimum-supported-zsh-version)

## Installation

### Manual

```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc
```

This is the simplest kind of installation and it works even if you are using a plugin manager. Just
make sure to disable your current theme in your plugin manager. See
[FAQ](#i-cannot-make-powerlevel10k-work-with-my-plugin-manager-help) for help.

### Oh My Zsh

```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
```

Set `ZSH_THEME=powerlevel10k/powerlevel10k` in your `~/.zshrc`.

### Prezto

Add `zstyle :prezto:module:prompt theme powerlevel10k` to your `~/.zpreztorc`.

### Antigen

Add `antigen theme romkatv/powerlevel10k` to your `~/.zshrc`. Make sure you have `antigen apply`
somewhere after it.

### Zplug

Add `zplug romkatv/powerlevel10k, as:theme, depth:1` to your `~/.zshrc`.

### Zgen

Add `zgen load romkatv/powerlevel10k powerlevel10k` to your `~/.zshrc`.

### Antibody

Add `antibody bundle romkatv/powerlevel10k` to your `~/.zshrc`.

### Zplugin

Add `zplugin ice depth=1; zplugin light romkatv/powerlevel10k` to your `~/.zshrc`.

The use of `depth=1` ice is optional. Other types of ice are neither recommended nor officially
supported by Powerlevel10k.

## Configuration

### For new users

On the first run Powerlevel10k configuration wizard will ask you a few questions and configure
your prompt. If it doesn't trigger automatically, type `p10k configure`. You can further customize
your prompt by editing `~/.p10k.zsh`.

### For Powerlevel9k users

If you've been using Powerlevel9k before, **do not remove the configuration options**. Powerlevel10k
will pick them up and provide you with the same prompt UI you are used to. Powerlevel10k recognized
all configuration options used by Powerlevel9k. See Powerlevel9k
[configuration guide](https://github.com/Powerlevel9k/powerlevel9k/blob/master/README.md#prompt-customization).

To go beyond the functionality of Powerlevel9k, type `p10k configure` and explore the unique styles
and features Powerlevel10k has to offer. You can further customize your prompt by editing
`~/.p10k.zsh`.

## Fonts

Powerlevel10k doesn't require custom fonts but can take advantage of them if they are available.
It works well with [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts),
[Source Code Pro](https://github.com/adobe-fonts/source-code-pro),
[Font Awesome](https://fontawesome.com/), [Powerline](https://github.com/powerline/fonts), and even
the default system fonts. The full choice of style options is available only when using
[Nerd Fonts](https://github.com/ryanoasis/nerd-fonts).

### Recommended: Meslo Nerd Font patched for Powerlevel10k

Download these four ttf files:
- [MesloLGS NF Regular.ttf](https://github.com/romkatv/dotfiles-public/raw/master/.local/share/fonts/NerdFonts/MesloLGS%20NF%20Regular.ttf)
- [MesloLGS NF Bold.ttf](https://github.com/romkatv/dotfiles-public/raw/master/.local/share/fonts/NerdFonts/MesloLGS%20NF%20Bold.ttf)
- [MesloLGS NF Italic.ttf](https://github.com/romkatv/dotfiles-public/raw/master/.local/share/fonts/NerdFonts/MesloLGS%20NF%20Italic.ttf)
- [MesloLGS NF Bold Italic.ttf](https://github.com/romkatv/dotfiles-public/raw/master/.local/share/fonts/NerdFonts/MesloLGS%20NF%20Bold%20Italic.ttf)

Double-click on each file and press "Install". This will make `MesloLGS NF` font available to all
applications on your system. Configure your terminal to use this font:

- **iTerm2**: Type `p10k configure`, answer `Yes` when asked whether to install
  *Meslo Nerd Font* and restart iTerm2 for the changes to take effect. Alternatively, open
  *iTerm2 → Preferences → Profiles → Text* and set *Font* to `MesloLGS NF`.
- **Apple Terminal** Open *Terminal → Preferences → Profiles → Text*, click *Change* under *Font*
  and select `MesloLGS NF` family.
- **Hyper**: Open *Hyper → Edit → Preferences* and change the value of `fontFamily` under
  `module.exports.config` to `MesloLGS NF`.
- **Visual Studio Code**: Open *File → Preferences → Settings*, enter
  `terminal.integrated.fontFamily` in the search box and set the value to `MesloLGS NF`.
- **GNOME Terminal** (the default Ubuntu terminal): Open *Terminal → Preferences* and click on the
  selected profile under *Profiles*. Check *Custom font* under *Text Appearance* and select
  `MesloLGS NF Regular`.
- **Konsole**: Open *Settings → Edit Current Profile → Appearance*, click *Select Font* and select
  `MesloLGS NF Regular`.
- **Tilix**: Open *Tilix → Preferences* and click on the selected profile under *Profiles*. Check
  *Custom font* under *Text Appearance* and select `MesloLGS NF Regular`.
- **Windows Console Host** (the old thing): Click the icon in the top left corner, then
  *Properties → Font* and set *Font* to `MesloLGS NF`.
- **Windows Terminal** (the new thing): Open *Settings* (`Ctrl+,`), search for `fontFace` and set
  value to `MesloLGS NF` for every profile.
- **Termux**: Type `p10k configure` and answer `Yes` when asked whether to install
  *Meslo Nerd Font*.

Run `p10k configure` to pick the best style for your new font.

_Using a different terminal and know how to set font for it? Share your knowledge by sending a PR
to expand the list!_

## Try it in Docker

Try Powerlevel10k in Docker. You can safely make any changes to the file system while trying out
the theme. Once you exit zsh, the image is deleted.

```zsh
docker run -e TERM -it --rm archlinux/base bash -uexc '
  pacman -Sy --noconfirm zsh git
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo "source ~/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc
  cd ~/powerlevel10k
  exec zsh'
```

## Is it really fast?

Yes.

[![asciicast](https://asciinema.org/a/NHRjK3BMePw66jtRVY2livHwZ.svg)](https://asciinema.org/a/NHRjK3BMePw66jtRVY2livHwZ)

Benchmark results obtained with
[zsh-prompt-benchmark](https://github.com/romkatv/zsh-prompt-benchmark) on an Intel i9-7900X
running Ubuntu 18.04 with the config from the demo.

| Theme               | Prompt Latency |
|---------------------|---------------:|
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

## License

Powerlevel10k is released under the
[MIT license](https://github.com/romkatv/powerlevel10k/blob/master/LICENSE). Contributions are
covered by the same license.

## FAQ

### <a name='instant-prompt'></a>What is instant prompt?

*Instant Prompt* is an optional feature of Powerlevel10k. When enabled, it gives you a limited
prompt within a few milliseconds of starting zsh, alowing you to start hacking right away while zsh
is initializing. Once initialization is complete, the full-featured Powerlevel10k prompt will
seamlessly replace instant prompt.

You can enable instant prompt either by running `p10k configure` or by manually adding the following
code snippet at the top of `~/.zshrc`:

```zsh
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
```

It's important that you copy the lines verbatim. Don't replace `source` with something else, don't
call `zcompile`, don't redirect output, etc.

When instant prompt is enabled, for the duration of zsh initialization standard input is redirected
to `/dev/null` and standard output with standard error are redirected to a temporary file. Once zsh
is fully initialized, standard file descriptors are restored and the content of the temporary file
is printed out.

When using instant prompt, you should carefully check any output that appears on zsh startup as it
may indicate that initialization has been altered, or perhaps even broken, by instant prompt.
Initialization code that may require console input, such as asking for a keyring password or for a
*[y/n]* confirmation, must be moved above the instant prompt preamble in `~/.zshrc`. Initialization
code that merely prints to console but never reads from it will work correctly with instant prompt,
although output that normally has colors may appear uncolored. You can either leave it be, suppress
the output, or move it above the instant prompt preamble.

Here's an example of `~/.zshrc` that breaks when instant prompt is enabled:

```zsh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

keychain id_rsa --agents ssh  # asks for password
chatty-script                 # spams to stdout even when everything is fine
```

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
```

If `POWERLEVEL9K_INSTANT_PROMPT` is unset or set to `verbose`, Powerlevel10k will print a warning
when it detects console output during initialization to bring attention to potential issues. You can
silence this warning (without suppressing console output) with `POWERLEVEL9K_INSTANT_PROMPT=quiet`.
This is recommended if some initialization code in `~/.zshrc` prints to console and it's infeasible
to move it above the instant prompt preamble or to suppress its output. You can completely disable
instant prompt with `POWERLEVEL9K_INSTANT_PROMPT=off`. Do this if instant prompt breaks zsh
initialization and you don't know how to fix it.

*NOTE: Instant prompt requires zsh >= 5.4. It's OK to enable it even when using an older version of
zsh but it won't do anything.*

### Why do my icons and/or powerline symbols look bad?

It's likely your font's fault.
[Install the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k) and run
`p10k configure`.

### I'm getting "character not in range" error. What gives?

Type `echo '\u276F'`. If you get an error saying "zsh: character not in range", your locale
doesn't support UTF-8. You need to fix it. If you are running zsh over SSH, see
[this](https://github.com/romkatv/powerlevel10k/issues/153#issuecomment-518347833). If you are
running zsh locally, Google "set UTF-8 locale in *your OS*".

### Why is my cursor in the wrong place?

Type `echo '\u276F'`. If you get an error saying "zsh: character not in range", see the
[previous question](#im-getting-character-not-in-range-error-what-gives).

If the `echo` command prints `❯` but the cursor is still in the wrong place, install
[the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k) and run
`p10k configure`.

If this doesn't help, add `unset ZLE_RPROMPT_INDENT` at the bottom of `~/.zshrc`.

Still having issues? Run the following command to diagnose the problem:

```zsh
() {
  emulate -L zsh
  setopt err_return no_unset
  local text
  print -rl -- 'Select a part of your prompt from the terminal window and paste it below.' ''
  read -r '?Prompt: ' text
  local -i len=${(m)#text}
  local frame="+-${(pl.$len..-.):-}-+"
  print -lr -- $frame "| $text |" $frame
}
```

#### If the prompt line aligns with the frame

```text
+------------------------------+
| romka@adam ✓ ~/powerlevel10k |
+------------------------------+
```

If the output of the command is aligned for every part of your prompt (left and right), this
indicates a bug in the theme or your config. Use this command to diagnose it:

```zsh
print -rl -- ${(eq+)PROMPT} ${(eq+)RPROMPT}
```

Look for `%{...%}` and backslash escapes in the output. If there are any, they are the likely
culprits. Open an issue if you get stuck.

#### If the prompt line is longer than the frame

```text
+-----------------------------+
| romka@adam ✓ ~/powerlevel10k |
+-----------------------------+
```

This is usually caused by a terminal bug or misconfiguration that makes it print ambiguous-width
characters as double-width instead of single width. For example,
[this issue](https://github.com/romkatv/powerlevel10k/issues/165).

#### If the prompt line is shorter than the frame and is mangled

```text
+------------------------------+
| romka@adam ✓~/powerlevel10k |
+------------------------------+
```

Note that this prompt is different from the original as it's missing a space after the checkmark.

This can be caused by a low-level bug in macOS. See
[this issue](https://github.com/romkatv/powerlevel10k/issues/241).

#### If the prompt line is shorter than the frame and is not mangled

```text
+--------------------------------+
| romka@adam ✓ ~/powerlevel10k |
+--------------------------------+
```

This can be caused by misconfigured locale. See
[this issue](https://github.com/romkatv/powerlevel10k/issues/251).

### Why is my prompt wrapping around in a weird way?

See [Why is my cursor in the wrong place?](#why-is-my-cursor-in-the-wrong-place)

### Why is my right prompt in the wrong place?

See [Why is my cursor in the wrong place?](#why-is-my-cursor-in-the-wrong-place)

### I cannot install the recommended font. Help!

Once you download [the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k),
you can install it just like any other font. Google "how to install fonts on *your OS*".

### Why do I have a question mark symbol in my prompt? Is my font broken?

If it looks like a regular `?`, that's normal. It means you have untracked files in the current Git
repository. Type `git status` to see these files. You can change this symbol or disable the display
of untracked files altogether. Search for `untracked files` in `~/.p10k.zsh`.

You can also get a weird-looking question mark in your prompt if your terminal's font is missing
some glyphs. To fix this problem,
[install the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k) and run
`p10k configure`.

### What do different symbols in Git status mean?

When using *Lean*, *Classic* or *Rainbow* style, Git status may look like this:

```text
feature:master ⇣42⇡42 *42 merge ~42 +42 !42 ?42
```

| Symbol    | Meaning                                                              | Source                                                 |
| --------- | -------------------------------------------------------------------- | ------------------------------------------------------ |
| `feature` | current branch; replaced with `#tag` or `@commit` if not on a branch | `git status`                                           |
| `master`  | remote tracking branch; only shown if different from local branch    | `git rev-parse --abbrev-ref --symbolic-full-name @{u}` |
| `⇣42`     | this many commits behind the remote                                  | `git status`                                           |
| `⇡42`     | this many commits ahead of the remote                                | `git status`                                           |
| `*42`     | this many stashes                                                    | `git stash list`                                       |
| `merge`   | repository state                                                     | `git status`                                           |
| `~42`     | this many merge conflicts                                            | `git status`                                           |
| `+42`     | this many staged changes                                             | `git status`                                           |
| `!42`     | this many unstaged changes                                           | `git status`                                           |
| `?42`     | this many untracked files                                            | `git status`                                           |

See also: [How do I change the format of Git status?](#how-do-i-change-the-format-of-git-status)

### How do I change the format of Git status?

To change the format of Git status, open `~/.p10k.zsh`, search for `my_git_formatter` and edit its
source code.

### How do I add username and/or hostname to prompt?

When using *Lean*, *Classic* or *Rainbow* style, prompt shows `username@hostname` when you are
logged in as root or via SSH. There is little value in showing `username` or `hostname` when you are
logged in to your local machine as a normal user. So the absence of `username@hostname` in your
prompt is an indication that you are working locally and that you aren't root. You can change it,
however.

Open `~/.p10k.zsh`. Close to the top you can see the most important parameters that define which
segments are shown in your prompt. All generally useful prompt segments are listed in there. Some of
them are enabled, others are commented out. One of them is of interest to you.

```zsh
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  ...
  context                 # user@hostname
  ...
)
```

Search for `context` to find the section in the config that lists parameters specific to this prompt
segment. You should see the following lines:

```zsh
# Don't show context unless running with privileges or in SSH.
# Tip: Remove the next line to always show context.
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
```

If you follow the tip and remove (or comment out) the last line, you'll always see
`username@hostname` in prompt. You can change the format to just `username`, or change the color, by
adjusting the values of parameters nearby. There are plenty of comments to help you navigate.

Finally, you can move `context` segment to where you want it to be in your prompt. Perhaps somewhere
within `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS`.

### Why does Powerlevel10k spawn extra processes?

Powerlevel10k uses [gitstatus](https://github.com/romkatv/gitstatus) as the backend behind `vcs`
prompt; gitstatus spawns `gitstatusd` and `zsh`. See
[gitstatus](https://github.com/romkatv/gitstatus) for details. Powerlevel10k may also spawn `zsh`
to trigger async prompt refresh. To avoid security hazard, these background processes aren't shared
by different interactive shells.

### Are there configuration options that make Powerlevel10k slow?

No, Powerlevel10k is always fast, with any configuration you throw at it. If you have noticeable
prompt latency when using Powerlevel10k, please
[open an issue](https://github.com/romkatv/powerlevel10k/issues).

### Is Powerlevel10k fast to load?

Yes, provided that you are using zsh >= 5.4.

Loading time, or time to first prompt, can be measured with the following benchmark:

```zsh
time (repeat 1000 zsh -dfis <<< 'source ~/powerlevel10k/powerlevel10k.zsh-theme')
```

*NOTE: This measures time to first complete prompt. Powerlevel10k can also display a
[limited prompt](#what-is-instant-prompt) before the full-featured prompt is ready.*

Running this command with `~/powerlevel10k` as the current directory on the same machine as in the
[prompt benchmark](#is-it-really-fast) takes 29 seconds (29 ms per invocation). This is about 6
times faster than powerlevel9k/master and 17 times faster than powerlevel9k/next.

### Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?

This is the goal. You should be able to switch from Powerlevel9k to Powerlevel10k with no
visible changes except for performance. There are, however, several differences.

- By default only `git` vcs backend is enabled in Powerlevel10k. If you need `svn` and `hg`, you'll
  need to add them to `POWERLEVEL9K_VCS_BACKENDS`.
- Powerlevel10k strives to be bug-compatible with Powerlevel9k but not when it comes to egregious
  bugs. If you accidentally rely on these bugs, your prompt will differ between Powerlevel9k and
  Powerlevel10k. Some examples:
  - Powerlevel9k doesn't respect `ZLE_RPROMPT_INDENT`. As a result, right prompt in Powerlevel10k
    can have an extra space at the end compared to Powerlevel9k. Set `ZLE_RPROMPT_INDENT=0` if you
    don't want that space.
  - Powerlevel9k ignores some options that are set after the theme is sourced while Powerlevel10k
    respects all options. If you see different icons in Powerlevel9k and Powerlevel10k, you've
    probably defined `POWERLEVEL9K_MODE` before sourcing the theme. This parameter gets ignored
    by Powerlevel9k but honored by Powerlevel10k. If you want your prompt to look in Powerlevel10k
    the same as in Powerlevel9k, remove `POWERLEVEL9K_MODE`.
  - There are
    [dozens more bugs](https://github.com/Powerlevel9k/powerlevel9k/issues/created_by/romkatv) in
    Powerlevel9k that don't exist in Powerlevel10k.

If you notice any other changes in prompt appearance when switching from Powerlevel9k to
Powerlevel10k, please [open an issue](https://github.com/romkatv/powerlevel10k/issues).

### Is there an AUR package for Powerlevel10k?

Yes, [zsh-theme-powerlevel10k-git](https://aur.archlinux.org/packages/zsh-theme-powerlevel10k-git/).
This package is owned by an unaffiliated volunteer.

### I cannot make Powerlevel10k work with my plugin manager. Help!

If the [installation instructions](#installation) didn't work for you, try disabling your current
theme (so that you end up with no theme) and then installing Powerlevel10k manually.

1. Disable the current theme in your framework / plugin manager.

- **zplug:** Open `~/.zshrc` and remove the `zplug` command that refers to your current theme. For
  example, if you are currently using Powerlevel9k, look for
  `zplug bhilburn/powerlevel9k, use:powerlevel9k.zsh-theme`.
- **prezto:** Open `~/.zpreztorc` and put `zstyle :prezto:module:prompt theme off` in it. Remove
  any other command that sets `theme` such as `zstyle :prezto:module:prompt theme powerlevel9k`.
- **oh-my-zsh:** Open `~/.zshrc` and remove the line that sets `ZSH_THEME`, such as
  `ZSH_THEME=powerlevel9k/powerlevel9k`.
- **antigen:** Open `~/.zshrc` and remove the line that sets `antigen theme`, such as
  `antigen theme powerlevel9k/powerlevel9k`.

2. Install Powerlevel10k manually.

```zsh
git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc
```

This method of installation won't make anything slower or otherwise sub-par.

### What is the minimum supported zsh version?

Zsh 5.1 or newer should work. Fast startup requires zsh >= 5.4.
