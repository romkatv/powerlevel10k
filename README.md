# Powerlevel10k

Powerlevel10k is a theme for ZSH. It's a backward-compatible fork of
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k) with lower latency and better
prompt responsiveness.

If you like the looks of Powerlevel9k but feeling frustrated by its slow prompt,
simply replace your `powerlevel9k` theme with `powerlevel10k` and enjoy responsive
shell like it's 80's again!

Powerlevel10k uses the same configuration options as Powerlevel9k and produces the
same results [[*]](#does-powerlevel10k-always-render-exactly-the-same-prompt-with-the-same-config).
It's simply faster.

## Table of Contents

1. [Installation and configuration](#installation-and-configuration)
   1. [Manual installation](#manual-installation)
   2. [Extra configuration](#extra-configuration)
2. [Try it out](#try-it-out)
   1. [For Powerlevel9k users](#for-powerlevel9k-users)
   2. [For new users](#for-new-users)
   3. [Docker playground](#docker-playground)
3. [How fast is it?](#how-fast-is-it)
4. [FAQ](#faq)
   1. [Why does Powerlevel10k spawn two extra processes?](#why-does-powerlevel10k-spawn-two-extra-processes)
   2. [Does Powerlevel10k always render exactly the same prompt with the same config?](#does-powerlevel10k-always-render-exactly-the-same-prompt-with-the-same-config)
   3. [Are changes getting up/down-streamed?](#are-changes-getting-updown-streamed)
   4. [Is there an AUR package for Powerlevel10k?](#is-there-an-aur-package-for-powerlevel10k)
   5. [How do I use Powerlevel10k with zplug, prezto, oh-my-zsh, antigen, somethingelse?](#how-do-i-use-powerlevel10k-with-zplug-prezto-oh-my-zsh-antigen-somethingelse)
   5. [What is the minimum supported zsh version?](#what-is-the-minimum-supported-zsh-version)

## Installation and configuration

For installation and configuration instructions see
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k). Everything in there applies to
Powerlevel10k as well. Follow the official installation guide, make sure everything works
and you like the way prompt looks. Then simply replace Powerlevel9k with Powerlevel10k. Once
you restart zsh, your prompt will be faster. No configuration changes are needed.

### Manual installation

```zsh
git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc
```

If you are using a framework / plugin manager and need help translating these instruction into its
configuration language, see [FAQ](#faq).

Make sure to disable your current theme.

### Extra configuration

Powerlevel10k has a handful of configuration options that Powerlevel9k doesn't have. They
are still using the `POWERLEVEL9K` prefix though.

  * `POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS (FLOAT) [default=0.05]`

      If it takes longer than this to fetch git repo status, display the prompt with a greyed out
      vcs segment and fix it asynchronously when the results come it.
  * `POWERLEVEL9K_VCS_BACKENDS (ARRAY) [default=(git)]`
  
      The list of VCS backends to use. Supported values are `git`, `svn` and `hg`. Note that adding
      anything other than git will make prompt slower even when your current directory isn't a repo.

  * `POWERLEVEL9K_GITSTATUS_DIR (STRING) [default=$POWERLEVEL9K_INSTALLATION_DIR/gitstatus]`

    Directory with gitstatus plugin. By default uses a copy bundled with Powerlevel10k.
  * `POWERLEVEL9K_DISABLE_GITSTATUS (STRING) [default="false"]`
  
    If set to `"true"`, Powerlevel10k won't use its fast git backend and will fall back to
    `vcs_info` like Powerlevel9k.
  * `POWERLEVEL9K_MAX_CACHE_SIZE (INT) [default=10000]`

    The maximum number of elements that can be stored in the cache. When the cache grows over this
    limit, it gets cleared.
  * `POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY (INT) [default=-1]`

    Don't scan for dirty files in git repos with more files in the index than this. Instead, show
    them with the "dirty" color (yellow by default) whether they are dirty or not. This makes git
    prompt much faster on huge repositories.

  * `POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME (STRING) [default="false"]`

    If set to `"true"`, `time` segment will update every second, turning into a realtime clock.
    This option appears to trigger a
    [bug in completion menu](https://www.zsh.org/mla/workers//2019/msg00161.html) in zsh.

## Try it out

Try Powerlevel10k without making any changes to your setup. If you like it, see
[Installation and configuration](#installation-and-configuration) for how to make a permanent
switch.

### For Powerlevel9k users

If you are currently using Powerlevel9k, you can try Powerlevel10k in a temporary zsh shell. The
prompt will look exactly like what you are used to but it'll be faster.

```zsh
git clone https://github.com/romkatv/powerlevel10k.git /tmp/powerlevel10k
source /tmp/powerlevel10k/powerlevel10k.zsh-theme
```

When you are done playing, `rm -rf /tmp/powerlevel10k` and exit zsh.

### For new users

```zsh
git clone https://github.com/romkatv/powerlevel10k.git /tmp/powerlevel10k
echo "
  # Your prompt configuration goes here.
  POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(root_indicator dir_writable dir vcs)
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)
  source /tmp/powerlevel10k/powerlevel10k.zsh-theme" >/tmp/powerlevel10k/.zshrc
ZDOTDIR=/tmp/powerlevel10k zsh
```

When you are done playing, `rm -rf /tmp/powerlevel10k` and exit zsh.

### Docker playground

You can try Powerlevel10k in Docker (Linux only). Once you exit zsh, the image is deleted.

```zsh
docker run -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -e TERM=$TERM -it --rm ubuntu bash -uexc '
  apt update && apt install -y zsh git
  git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo "
    # Your prompt configuration goes here.
    POWERLEVEL9K_PROMPT_ON_NEWLINE=true
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(root_indicator dir_writable dir vcs)
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)
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
POWERLEVEL9K_ROOT_ICON=\\uF09C
POWERLEVEL9K_TIME_ICON=\\uF017
POWERLEVEL9K_TIME_BACKGROUND=magenta
POWERLEVEL9K_STATUS_OK_BACKGROUND=grey53
```

Powerlevel10k shows similar performance advantage over Powerlevel9k on Mac OS, FreeBSD, WSL, and
Raspberry Pie.

## FAQ

### Why does Powerlevel10k spawn extra processes?

Powerlevel10k uses [gitstatus](https://github.com/romkatv/gitstatus) as the backend behind `vcs`
prompt; gitstatus spawns `gitstatusd` and `zsh`. See
[gitstatus](https://github.com/romkatv/gitstatus) for details. Powerlevel10k spawns another `zsh`
if `POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME` is set to `true` or `background_jobs` segment is
enabled. This is used to trigger prompt refresh.

### Does Powerlevel10k always render exactly the same prompt with the same config?

This is the goal. You should be able to switch between Powerlevel9k and Powerlevel10k with no
visible changes except for performance. There are, however, several differences.

  * Git prompt in Powerlevel10k doesn't show tags and revisions. Open an issue if you need them.
  * By default only git vcs backend is enabled in Powerlevel10k. If you need svn and hg, you'll
    need to set `POWERLEVEL9K_VCS_BACKENDS`. See [Extra configuration](#extra-configuration).
  * Fewer configuration options can be changed after the theme is loaded. For example, if you
    decide to change background color of some segment in the middle of an interactive session,
    it may not work.

If you notice any other differences between prompts in Powerlevel9k and Powerlevel10k when running
with the same settings, please [open an issue](https://github.com/romkatv/powerlevel10k/issues).

### Are changes getting up/down-streamed?

Powerlevel10k regularly pulls changes from Powerlevel9k, so all bug fixes and new features that land
in Powerlevel9k will land here, too.

There is ongoing work on upstreaming some of the changes from Powerlevel10k to Powerlevel9k. E.g.,
issues [1170](https://github.com/bhilburn/powerlevel9k/issues/1170) and
[1185](https://github.com/bhilburn/powerlevel9k/issues/1185).

Improvements to [libgit2](https://github.com/libgit2/libgit2/issues/4230#issuecomment-471710359) are
being upstremed. There are 3 independent optimizations and it's not yet clear whether all of them
will make it but there is a good chance they will.

### Is there an AUR package for Powerlevel10k?

Yes, [zsh-theme-powerlevel10k-git](https://aur.archlinux.org/packages/zsh-theme-powerlevel10k-git/).
This package is owned by an unaffiliated volunteer.

### How do I use Powerlevel10k with zplug, prezto, oh-my-zsh, antigen, somethingelse?

If you have to ask, then the easiest way is to disable the current theme (so that you end up with
no theme) and then install Powerlevel10k the usual way.

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

2. Install Powerlevel10k the usual way.

```zsh
git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc
```

### What is the minimum supported zsh version?

Anything below 5.2 definitely won't work. 5.4 definitely will.
