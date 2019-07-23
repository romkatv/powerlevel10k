# Powerlevel10k

Powerlevel10k is a theme for ZSH. It's a backward-compatible modern reimplementation of
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k) with lower latency, better
prompt responsiveness and scores of extra features.

Powerlevel10k can be used as a drop-in replacement for Powerlevel9k. When given the same
configuration options it will generate
[the same](#does-powerlevel10k-always-render-exactly-the-same-prompt-as-powerlevel9k-given-the-same-config)
prompt. It will be [much faster](#is-it-really-fast) though.

![p10k-lean](https://raw.githubusercontent.com/romkatv/powerlevel10k/master/config/p10k-lean.png)

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
   1. [For new users](#for-new-users)
   1. [For existing users](#for-existing-users)
1. [Fonts](#fonts)
1. [Try it in Docker](#try-it-in-docker)
1. [Is it really faster?](#is-it-really-fast)
1. [License](#license)
1. [FAQ](#faq)
   1. [Why does Powerlevel10k spawn extra processes?](#why-does-powerlevel10k-spawn-extra-processes)
   1. [Are there configuration options that make Powerlevel10k slow?](#are-there-configuration-options-that-make-powerlevel10k-slow)
   1. [Is Powerlevel10k fast to load?](#is-powerlevel10k-fast-to-load)
   1. [Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?](#does-powerlevel10k-always-render-exactly-the-same-prompt-as-powerlevel9k-given-the-same-config)
   1. [I am getting an error: "zsh: bad math expression: operand expected at end of string"](#i-am-getting-an-error-zsh-bad-math-expression-operand-expected-at-end-of-string)
   1. [Is there an AUR package for Powerlevel10k?](#is-there-an-aur-package-for-powerlevel10k)
   1. [I cannot make Powerlevel10k work with my plugin manager. Help!](#i-cannot-make-powerlevel10k-work-with-my-plugin-manager-help)
   1. [What is the minimum supported ZSH version?](#what-is-the-minimum-supported-zsh-version)

## Installation

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

### For new users

If you are new to Powerlevel10k/9k and don't have your own config yet, start with the
[lean](https://github.com/romkatv/powerlevel10k/blob/master/config/p10k-lean.zsh) style.

```zsh
curl -fsSL -o ~/p10k-lean.zsh https://raw.githubusercontent.com/romkatv/powerlevel10k/master/config/p10k-lean.zsh
echo 'source ~/p10k-lean.zsh' >>! ~/.zshrc
```

That's it! Your have a fast and functional prompt. If you want to customize it, edit
`~/p10k-lean.zsh` and restart ZSH.

### For existing users

If you've been using Powerlevel9k before, **do not remove the configuration options**. Powerlevel10k
will pick them up and provide you with the same prompt UI you are used to. Powerlevel10k recognized
all configuration options used by Powerlevel9k. See Powerlevel9k
[configuration guide](https://github.com/bhilburn/powerlevel9k#prompt-customization).

If you aren't completely satisfied with your prompt or looking for something fresh, try
[lean](https://github.com/romkatv/powerlevel10k/blob/master/config/p10k-lean.zsh) config.

## Fonts

Depending on your configuration, you might need to install a Powerline font. Follow the
[font installation guide](https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions#step-2-install-a-powerline-font)
from Powerlevel9k.

[Lean](https://github.com/romkatv/powerlevel10k/blob/master/config/p10k-lean.zsh) config doesn't
require custom fonts. It'll work even with regular system fonts. If you are having trouble with
Powerline fonts, try this config.

## Try it in Docker

Try Powerlevel10k in Docker. You can safely make any changes to the file system while trying out
the theme. Once you exit zsh, the image is deleted.

```zsh
docker run -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -e TERM -it --rm ubuntu bash -uexc '
  cd && apt update && apt install -y zsh git
  git clone https://github.com/romkatv/powerlevel10k.git
  cp ~/powerlevel10k/config/p10k-lean.zsh ~/
  echo "source ~/p10k-lean.zsh" >>~/.zshrc
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

### Why does Powerlevel10k spawn extra processes?

Powerlevel10k uses [gitstatus](https://github.com/romkatv/gitstatus) as the backend behind `vcs`
prompt; gitstatus spawns `gitstatusd` and `zsh`. See
[gitstatus](https://github.com/romkatv/gitstatus) for details. Powerlevel10k may also spawn `zsh`
to trigger async prompt refresh.

### Are there configuration options that make Powerlevel10k slow?

No, Powerlevel10k is always fast, with any configuration you throw at it. If you have noticeable
prompt latency when using Powerlevel10k, please
[open an issue](https://github.com/romkatv/powerlevel10k/issues).

### Is Powerlevel10k fast to load?

The short answer is no. The amount of time it takes for Powerlevel10k to render the first prompt
is in the same ballpark as for Powerlevel9k.

Time to first prompt can be measured with the following benchmark:

```zsh
time (repeat 100 zsh -dfis <<< 'source ~/powerlevel10k/powerlevel10k.zsh-theme')
```

On the same machine as in the [prompt benchmark](#is-it-really-fast) this results in 147 ms per
invocation when executed in a small git repository (I used the `powerlevel10k` repo itself). For
comparison, the same benchmark gives 170 ms for powerlevel9k/master and 505 ms for
powerlevel9k/next.

If your workflow requires that you open a terminal tab, type a command or two and close the tab,
Powerlevel10k isn't the best choice. Powerlevel10k is optimized for long-lived ZSH sessions.

### Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?

This is the goal. You should be able to switch between Powerlevel9k and Powerlevel10k with no
visible changes except for performance. There are, however, several differences.

  * By default only git vcs backend is enabled in Powerlevel10k. If you need svn and hg, you'll
    need to set `POWERLEVEL9K_VCS_BACKENDS`.
  * Fewer configuration options can be changed after the theme is loaded. For example, if you
    decide to change background color of some segment in the middle of an interactive ZSH session,
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
