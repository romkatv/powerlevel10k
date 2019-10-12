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
   1. [Why my icons and/or powerline symbols look bad?](#why-my-icons-andor-powerline-symbols-look-bad)
   1. [Why is my cursor in the wrong place?](#why-is-my-cursor-in-the-wrong-place)
   1. [Why is my right prompt wrapping around in a weird way?](#why-is-my-right-prompt-wrapping-around-in-a-weird-way)
   1. [I cannot install the recommended font. Help!](#i-cannot-install-the-recommended-font-help)
   1. [Why do I have a question mark symbol in my prompt? Is my font broken?](#why-do-i-have-a-question-mark-symbol-in-my-prompt-is-my-font-broken)
   1. [Why does Powerlevel10k spawn extra processes?](#why-does-powerlevel10k-spawn-extra-processes)
   1. [Are there configuration options that make Powerlevel10k slow?](#are-there-configuration-options-that-make-powerlevel10k-slow)
   1. [Is Powerlevel10k fast to load?](#is-powerlevel10k-fast-to-load)
   1. [Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?](#does-powerlevel10k-always-render-exactly-the-same-prompt-as-powerlevel9k-given-the-same-config)
   1. [Is there an AUR package for Powerlevel10k?](#is-there-an-aur-package-for-powerlevel10k)
   1. [I cannot make Powerlevel10k work with my plugin manager. Help!](#i-cannot-make-powerlevel10k-work-with-my-plugin-manager-help)
   1. [What is the minimum supported ZSH version?](#what-is-the-minimum-supported-zsh-version)

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
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
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

The use of `depth` ice is optional. Other types of ice are neither recommended nor officially
supported by Powerlevel10k.

## Configuration

### For new users

On the first run Powerlevel10k configuration wizard will ask you a few questions and configure
your prompt. If it doesn't trigger automatically, type `p10k configure`.

### For Powerlevel9k users

If you've been using Powerlevel9k before, **do not remove the configuration options**. Powerlevel10k
will pick them up and provide you with the same prompt UI you are used to. Powerlevel10k recognized
all configuration options used by Powerlevel9k. See Powerlevel9k
[configuration guide](https://github.com/Powerlevel9k/powerlevel9k/blob/master/README.md#prompt-customization).

To go beyond the functionality of Powerlevel9k, type `p10k configure` and explore the unique styles
and features Powerlevel10k has to offer.

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

- **iTerm2**: Open *iTerm2 → Preferences → Profiles → Text* and set *Font* to `MesloLGS NF`.
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
- **Termux**: Type `p10k configure` and answer `Yes` when asked whether to install *Meslo Nerd Font*.

Run `p10k configure` to pick the best style for your new font.

_Using a different terminal and know how to set font for it? Share your knowledge by sending a PR
to expand the list!_

## Try it in Docker

Try Powerlevel10k in Docker. You can safely make any changes to the file system while trying out
the theme. Once you exit zsh, the image is deleted.

```zsh
docker run -e LANG=en_US.utf8 -e TERM -it --rm archlinux/base bash -uexc '
  pacman -Sy --noconfirm zsh git
  git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo "source ~/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc
  cd ~/powerlevel10k
  exec zsh'
```

## Is it really fast?

Yes.

[![asciicast](https://asciinema.org/a/NHRjK3BMePw66jtRVY2livHwZ.svg)](https://asciinema.org/a/NHRjK3BMePw66jtRVY2livHwZ)

Benchmark results obtained with
[zsh-prompt-benchmark](https://github.com/romkatv/zsh-prompt-benchmark) on Intel i9-7900X
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
instant with any configuration. It stays way below the 50 ms mark, leaving most of the latency
budget for other plugins you might install.

## License

Powerlevel10k is released under the
[MIT license](https://github.com/romkatv/powerlevel10k/blob/master/LICENSE). Contributions are
covered by the same license.

## FAQ

### Why my icons and/or powerline symbols look bad?

It's likely your font's fault.
[Install the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k) and run
`p10k configure`.

### Why is my cursor in the wrong place?

It's likely your font's fault.
[Install the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k) and run
`p10k configure`.

If this doesn't help, type `unset ZLE_RPROMPT_INDENT`. If it fixes the issue, make the change
permanent:

```zsh
echo 'unset ZLE_RPROMPT_INDENT' >>! ~/.zshrc
```

### Why is my right prompt wrapping around in a weird way?

It's likely your font's fault.
[Install the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k) and run
`p10k configure`.

If this doesn't help, type `unset ZLE_RPROMPT_INDENT`. If it fixes the issue, make the change
permanent:

```zsh
echo 'unset ZLE_RPROMPT_INDENT' >>! ~/.zshrc
```

### I cannot install the recommended font. Help!

Once you download [the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k),
you can install it just like any other font. Google "how to install fonts on *your-OS*".

### Why do I have a question mark symbol in my prompt? Is my font broken?

If it looks like a regular `?`, that's normal. It means you have untracked files in the current Git
repository. Type `git status` to see these files. You can change this symbol or disable the display
of untracked files altogether. Search for `untracked files` in `~/.p10k.zsh`.

You can also get a weird-looking question mark in your prompt if your terminal's font is missing
some glyphs. To fix this problem,
[install the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k) and run
`p10k configure`.

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

Yes, provided that you are using ZSH >= 5.4.

Loading time, or time to first prompt, can be measured with the following benchmark:

```zsh
time (repeat 1000 zsh -dfis <<< 'source ~/powerlevel10k/powerlevel10k.zsh-theme')
```

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

### What is the minimum supported ZSH version?

ZSH 5.1 or newer should work.

However, there are too many version, OS, platform, terminal and option configurations to test. If
Powerlevel10k doesn't work for you, please open an issue.
