# Powerlevel10k

Powerlevel10k is a theme for ZSH. It's a backward-compatible reimplementation of
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k) with lower latency and better
prompt responsiveness.

If you like the looks of Powerlevel9k but feeling frustrated by its slow prompt,
simply replace it with Powerlevel10k and enjoy responsive shell like it's 80's again!

Powerlevel10k is a drop-in replacement for Powerlevel9k. It uses the same configuration options as
Powerlevel9k and produces the same results
[[*]](#does-powerlevel10k-always-render-exactly-the-same-prompt-as-powerlevel9k-given-the-same-config).
It's simply [much faster](#is-it-really-fast).

## Table of Contents

1. [Installation](#installation)
   1. [Manual](#manual)
   1. [Oh My Zsh](#oh-my-zsh)
   1. [Prezto](#prezto)
   1. [Antigen](#antigen)
   1. [Zplug](#zplug)
   1. [Zgen](#zgen)
   1. [Antibody](#antibody)
1. [Configuration](#configuration)
1. [Fonts](#fonts)
1. [Try it out](#try-it-out)
   1. [For Powerlevel9k users](#for-powerlevel9k-users)
   1. [For new users](#for-new-users)
   1. [Docker playground](#docker-playground)
1. [Is it really faster?](#is-it-really-fast)
1. [License](#license)
1. [FAQ](#faq)
   1. [Why does Powerlevel10k spawn extra processes?](#why-does-powerlevel10k-spawn-extra-processes)
   1. [Are there configuration options that make Powerlevel10k slow?](#are-there-configuration-options-that-make-powerlevel10k-slow)
   1. [Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?](#does-powerlevel10k-always-render-exactly-the-same-prompt-as-powerlevel9k-given-the-same-config)
   1. [I am getting an error: "zsh: bad math expression: operand expected at end of string"](#i-am-getting-an-error-zsh-bad-math-expression-operand-expected-at-end-of-string)
   1. [Is there an AUR package for Powerlevel10k?](#is-there-an-aur-package-for-powerlevel10k)
   1. [I cannot make Powerlevel10k work with my plugin manager. Help!](#i-cannot-make-powerlevel10k-work-with-my-plugin-manager-help)
   1. [What is the minimum supported ZSH version?](#what-is-the-minimum-supported-zsh-version)

## Installation

Installation is virtually the same as in Powerlevel9k. If you managed to install Powerlevel9k, you'll be able to install Powerlevel10k.

### Manual

```zsh
git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
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

Add `zplug romkatv/powerlevel10k, use:powerlevel10k.zsh-theme` to your `~/.zshrc`.

### Zgen

Add `zgen load romkatv/powerlevel10k powerlevel10k` to your `~/.zshrc`.

### Antibody

Add `antibody bundle romkatv/powerlevel10k` to your `~/.zshrc`.

## Configuration

Powerlevel10k recognized all configuration options used by Powerlevel9k. See Powerlevel9k
[configuration guide](https://github.com/bhilburn/powerlevel9k#prompt-customization). Powerlevel10k
has a few
[extensions](https://github.com/romkatv/powerlevel10k/blob/master/EXTENDED_CONFIGURATION.md).

If you've been using Powerlevel9k before, **do not remove the configuration options**. Powerlevel10k
will pick them up and provide you with the same prompt UI you are used to.

The default configuration in Powerlevel10k is the same as in Powerlevel9k, which is to say it's not
pretty. [Pure Power](https://github.com/romkatv/dotfiles-public/blob/master/.purepower) is
recommended as a good starting point for new users. It'll make your prompt look like this.

![Pure Power](https://raw.githubusercontent.com/romkatv/dotfiles-public/master/dotfiles/purepower.png)

Installation of Pure Power is the same regardless of your plugin manager of choice.

```zsh
( cd && curl -fsSLO https://raw.githubusercontent.com/romkatv/dotfiles-public/master/.purepower )
echo 'source ~/.purepower' >>! ~/.zshrc
```

Pure Power needs to be installed _in addition_ to Powerlevel10k, not instead of it. `~/.purepower`
defines a set of configuration parameters that affect the styling of Powerlevel10k; there is no code
in it.

Read the documentation at the top of `~/.purepower` (or
[here](https://github.com/romkatv/dotfiles-public/blob/master/.purepower)) to get an idea of what
your prompt is capable of. You can edit the file to change your Powerlevel10k configuration.

## Fonts

Depending on your configuration, you might need to install a Powerline font. Follow the
[font installation guide](https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions#step-2-install-a-powerline-font)
from Powerlevel9k.

[Pure Power](https://github.com/romkatv/dotfiles-public/blob/master/.purepower) config doesn't
require custom fonts. It'll work even with regular system fonts. If you are having trouble with
patched fonts, try Pure Power.

## Try it out

Try Powerlevel10k without making any changes to your setup. If you like it, see
[installation](#installation) and [configuration](#configuration) for how to make a permanent
switch.

### For Powerlevel9k users

If you are currently using Powerlevel9k, you can try Powerlevel10k in a temporary zsh session. The
prompt will look exactly like what you are used to but it'll be faster.

```zsh
git clone https://github.com/romkatv/powerlevel10k.git /tmp/powerlevel10k
source /tmp/powerlevel10k/powerlevel10k.zsh-theme
```

When you are done playing, `rm -rf /tmp/powerlevel10k` and exit zsh. Feel the difference in prompt
latency.

### For new users

```zsh
git clone https://github.com/romkatv/powerlevel10k.git /tmp/powerlevel10k
(cd /tmp/powerlevel10k && curl -fsSLO https://raw.githubusercontent.com/romkatv/dotfiles-public/master/.purepower)
echo '
  source /tmp/powerlevel10k/.purepower
  source /tmp/powerlevel10k/powerlevel10k.zsh-theme' >/tmp/powerlevel10k/.zshrc
ZDOTDIR=/tmp/powerlevel10k zsh
```

When you are done playing, `rm -rf /tmp/powerlevel10k` and exit zsh.

### Docker playground

You can try Powerlevel10k in Docker (Linux only). You can safely make any changes to the file system
while trying out Powerlevel10k. Once you exit zsh, the image is deleted.

```zsh
docker run -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -e TERM=$TERM -it --rm ubuntu bash -uexc '
  apt update && apt install -y zsh git curl
  git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  cd && curl -fsSLO https://raw.githubusercontent.com/romkatv/dotfiles-public/master/.purepower
  echo "
    source ~/.purepower
    source ~/powerlevel10k/powerlevel10k.zsh-theme" >~/.zshrc
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
convered by the same license.

## FAQ

### Why does Powerlevel10k spawn extra processes?

Powerlevel10k uses [gitstatus](https://github.com/romkatv/gitstatus) as the backend behind `vcs`
prompt; gitstatus spawns `gitstatusd` and `zsh`. See
[gitstatus](https://github.com/romkatv/gitstatus) for details. Powerlevel10k spawns another `zsh`
if `POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME` is set to `true`. This is used to trigger prompt
refresh every second.

### Are there configuration options that make Powerlevel10k slow?

No, Powerlevel10k is always fast, with any configuration you throw at it. If you have noticeable
prompt latency when using Powerlevel10k, please
[open an issue](https://github.com/romkatv/powerlevel10k/issues).

### Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?

This is the goal. You should be able to switch between Powerlevel9k and Powerlevel10k with no
visible changes except for performance. There are, however, several differences.

  * By default only git vcs backend is enabled in Powerlevel10k. If you need svn and hg, you'll
    need to set `POWERLEVEL9K_VCS_BACKENDS`.
  * Powerlevel10k implements a few
    [extensions](https://github.com/romkatv/powerlevel10k/blob/master/EXTENDED_CONFIGURATION.md). If
    you use them, you'll get different prompt when you switch to Powerlevel9k. However, extensions
    are designed with graceful degradation in mind, so your prompt will still be functional.
  * Fewer configuration options can be changed after the theme is loaded. For example, if you
    decide to change background color of some segment in the middle of an interactive session,
    it may not work.

If you notice any other differences between prompts in Powerlevel9k and Powerlevel10k when running
with the same settings, please [open an issue](https://github.com/romkatv/powerlevel10k/issues).

### I am getting an error: "zsh: bad math expression: operand expected at end of string"

Did you change any `POWERLEVEL9K` options after the first prompt got rendered, perhaps by editing
your `~/.zshrc` and executing `source ~/.zshrc`? This isn't supported. You'll need to restart zsh
for configuration changes to take effect. Run `exec zsh` to do this without forking a process.

### Is there an AUR package for Powerlevel10k?

Yes, [zsh-theme-powerlevel10k-git](https://aur.archlinux.org/packages/zsh-theme-powerlevel10k-git/).
This package is owned by an unaffiliated volunteer.

### I cannot make Powerlevel10k work with my plugin manager. Help!

If the [installation instructions](#installation) didn't work for you, try disabling your current
theme (so that you end up with no theme) and then installing Powerlevel10k manually.

1. Disable the current theme in your framework / plugin manager.

  * **zplug:** Open `~/.zshrc` and remove the `zplug` command that refers to your current theme. For
    example, if you are currently using Powerlevel9k, look for
    `zplug bhilburn/powerlevel9k, use:powerlevel9k.zsh-theme`.
  * **prezto:** Open `~/.zpreztorc` and put `zstyle :prezto:module:prompt theme off` in it. Remove
    any other command that sets `theme` such as `zstyle :prezto:module:prompt theme powerlevel9k`.
  * **oh-my-zsh:** Open `~/.zshrc` and remove the line that sets `ZSH_THEME`, such as
    `ZSH_THEME=powerlevel9k/powerlevel9k`.
  * **antigen:** Open `~/.zshrc` and remove the line that sets `antigen theme`, such as
    `antigen theme bhilburn/powerlevel9k powerlevel9k`.

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
