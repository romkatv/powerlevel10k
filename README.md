# Powerlevel10k

Powerlevel10k is a theme for ZSH. It's a backward-compatible reimplementation of
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k) with lower latency and better
prompt responsiveness.

If you like the looks of Powerlevel9k but feeling frustrated by its slow prompt,
simply replace it with Powerlevel10k and enjoy responsive shell like it's 80's again!

Powerlevel10k is a drop-in replacement for Powerlevel9k. It uses the same configuration options as
Powerlevel9k and produces the same results
[[*]](#does-powerlevel10k-always-render-exactly-the-same-prompt-with-the-same-config).
It's simply [much faster](#how-fast-is-it).

## Table of Contents

1. [Installation](#installation)
   1. [Manual](#manual)
   2. [Oh My Zsh](#oh-my-zsh)
   3. [Prezto](#prezto)
   4. [Antigen](#antigen)
   5. [Zplug](#zplug)
   6. [Zgen](#zgen)
   7. [Antibody](#antibody)
2. [Configuration](#configuration)
3. [Try it out](#try-it-out)
   1. [For Powerlevel9k users](#for-powerlevel9k-users)
   2. [For new users](#for-new-users)
   3. [Docker playground](#docker-playground)
4. [How fast is it?](#how-fast-is-it)
5. [License](#license)
6. [FAQ](#faq)
   1. [Why does Powerlevel10k spawn extra processes?](#why-does-powerlevel10k-spawn-extra-processes)
   2. [Does Powerlevel10k always render exactly the same prompt with the same config?](#does-powerlevel10k-always-render-exactly-the-same-prompt-with-the-same-config)
   3. [I am getting an error: "zsh: bad math expression: operand expected at end of string"](#i-am-getting-an-error-zsh-bad-math-expression-operand-expected-at-end-of-string)
   3. [Are changes getting up/down-streamed?](#are-changes-getting-updown-streamed)
   4. [Is there an AUR package for Powerlevel10k?](#is-there-an-aur-package-for-powerlevel10k)
   5. [I cannot make Powerlevel10k work with my plugin manager. Help!](#i-cannot-make-powerlevel10k-work-with-my-plugin-manager-help)
   6. [What is the minimum supported zsh version?](#what-is-the-minimum-supported-zsh-version)

## Installation

If you don't yet have a Powerline font installed, follow the
[font installation guide](https://github.com/bhilburn/powerlevel9k/wiki/Install-Instructions#step-2-install-a-powerline-font)
from Powerlevel9k. Once you have a working Powerline font installed, proceed with the installation
of Powerlevel10k as described below.

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

```zsh
git clone https://github.com/romkatv/powerlevel10k.git  ~/.zprezto/modules/prompt/external/powerlevel10k
ln -s ~/.zprezto/modules/prompt/{external/powerlevel10k/powerlevel10k.zsh-theme,functions/prompt_powerlevel10k_setup}
```

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
[configuration guide](https://github.com/bhilburn/powerlevel9k#prompt-customization) for the full
list.

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

Powerlevel10k has configuration options that Powerlevel9k doesn't. See
[extended configuration](https://github.com/romkatv/powerlevel10k/blob/master/EXTENDED_CONFIGURATION.md).

## Try it out

Try Powerlevel10k without making any changes to your setup. If you like it, see
[installation](#installation) and [configuration](#configuration) for how to make a permanent
switch.

### For Powerlevel9k users

If you are currently using Powerlevel9k, you can try Powerlevel10k in a temporary zsh shell. The
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
  # Uncomment the following line if you see unprintable characters in your prompt
  # PURE_POWER_MODE=portable
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
    # Uncomment the following line if you see unprintable characters in your prompt
    # PURE_POWER_MODE=portable
    source ~/.purepower
    source ~/powerlevel10k/powerlevel10k.zsh-theme" >~/.zshrc
  cd ~/powerlevel10k
  zsh -i'
```

## How fast is it?

Powerlevel10k renders prompt between 10 and 100 times faster than powerlevel9k.

Here are benchmark results obtained with
[zsh-prompt-benchmark](https://github.com/romkatv/zsh-prompt-benchmark) on Intel i9-7900X
running Ubuntu 18.04.

| Theme               |        /  |   ~/linux |
|---------------------|----------:| ---------:|
| powerlevel9k/master |    101 ms |    280 ms |
| powerlevel9k/next   |     26 ms |    255 ms |
| **powerlevel10k**   |  **1 ms** | **22 ms** |
| naked zsh           |   0.05 ms |   0.05 ms |

Columns define the current directory where the prompt was rendered.

  * `/` -- root directory, not a git repo.
  * `~/linux` -- [linux](https://github.com/torvalds/linux) git repo with 60k files. It was checked
    out to an M.2 SSD.

powerlevel9k/master is the stable branch of powerlevel9k, the one that virtually everyone uses.
powerlevel9k/next is the development branch for the next release.

Here's how the prompt looked like during benchmarking.

![](https://raw.githubusercontent.com/romkatv/powerlevel10k/master/prompt.png)

It was identical in Powerlevel10k and Powerlevel9k. Even though Powerlevel10k can dynamically
switch to async prompts, it wasn't happening during the benchmark because latencies were low.
Prompts with both themes were essentially synchronous, with every prompt having up-to-date git info
(no greyed-out vcs/git segments).

Configuration that was used:

```zsh
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir_writable dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)

POWERLEVEL9K_MODE=nerdfont-complete
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_ROOT_ICON=$'\uF09C'
POWERLEVEL9K_TIME_ICON=$'\uF017'
POWERLEVEL9K_TIME_BACKGROUND=magenta
POWERLEVEL9K_STATUS_OK_BACKGROUND=grey53
```

Powerlevel10k shows similar performance advantage over Powerlevel9k on Mac OS, FreeBSD, WSL, and
Raspberry Pie.

## License

Powerlevel10k is released under the [MIT license](https://github.com/romkatv/powerlevel10k/blob/master/LICENSE). Contributions are convered by the same license.

## FAQ

### Why does Powerlevel10k spawn extra processes?

Powerlevel10k uses [gitstatus](https://github.com/romkatv/gitstatus) as the backend behind `vcs`
prompt; gitstatus spawns `gitstatusd` and `zsh`. See
[gitstatus](https://github.com/romkatv/gitstatus) for details. Powerlevel10k spawns another `zsh`
if `POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME` is set to `true`. This is used to trigger prompt
refresh every second.

### Does Powerlevel10k always render exactly the same prompt with the same config?

This is the goal. You should be able to switch between Powerlevel9k and Powerlevel10k with no
visible changes except for performance. There are, however, several differences.

  * By default only git vcs backend is enabled in Powerlevel10k. If you need svn and hg, you'll
    need to set `POWERLEVEL9K_VCS_BACKENDS`. See
    [extended configuration](https://github.com/romkatv/powerlevel10k/blob/master/EXTENDED_CONFIGURATION.md).
  * Fewer configuration options can be changed after the theme is loaded. For example, if you
    decide to change background color of some segment in the middle of an interactive session,
    it may not work.

If you notice any other differences between prompts in Powerlevel9k and Powerlevel10k when running
with the same settings, please [open an issue](https://github.com/romkatv/powerlevel10k/issues).

### I am getting an error: "zsh: bad math expression: operand expected at end of string"

Did you change any `POWERLEVEL9K` options after the first prompt got rendered, perhaps by editing
your `~/.zshrc` and executing `source ~/.zshrc`? This isn't supported. You'll need to restart zsh
for configuration changes to take effect. Run `exec zsh` to do this without forking a process.

### Are changes getting up/down-streamed?

Powerlevel10k regularly pulls changes from Powerlevel9k, so all bug fixes and new features that land
in Powerlevel9k will land here, too. This is a labor-intensive process because Powerlevel9k and
Powerlevel10k have very different code. Thankfully, there aren't many changes in Powerlevel9k.

There is ongoing work on upstreaming some of the performance improvements from Powerlevel10k to
Powerlevel9k. E.g., issues [1170](https://github.com/bhilburn/powerlevel9k/issues/1170) and
[1185](https://github.com/bhilburn/powerlevel9k/issues/1185).

I've opening issues for all bugs that I've inherited from Powerlevel9k during the fork and have
since fixed. They don't see much traction but at least the devs and users know about them.

Improvements to [libgit2](https://github.com/libgit2/libgit2/issues/4230#issuecomment-471710359) are
being upstreamed. There are 3 independent optimizations and it's not yet clear whether all of them
will make it but there is a good chance they will.

Fix to a [bug in zsh](https://www.zsh.org/mla/workers//2019/msg00204.html) that affects all async
themes might get upstreamed.

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

### What is the minimum supported zsh version?

ZSH 5.1 or newer should work.

However, there are too many version, OS, platform, terminal and option configurations to test. If
Powerlevel10k doesn't work for you, please open an issue.
