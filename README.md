# Powerlevel10k

Powerlevel10k is a theme for ZSH. It's a backward-compatible fork of
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k) with lower latency and better
prompt responsiveness.

If you like the looks of Powerlevel9k but feeling frustrated by its slow prompt,
simply replace your `powerlevel9k` theme with `powerlevel10k` and enjoy responsive
shell like it's 80's again!

Powerlevel10k uses the same configuration options as Powerlevel9k and produces the
same results. It's simply faster. There is no catch.

## Table of Contents

1. [Installation and configuration](#installation-and-configuration)
   1. [Manual installation](#manual-installation)
   2. [Extra configuration](#extra-configuration)
2. [Try it out](#try-it-out)
   1. [For Powerlevel9k users](#for-powerlevel9k-users)
   2. [For new users](#for-new-users)
   3. [Docker playground](#docker-playground)
3. [How fast is it?](#how-fast-is-it)
4. [What's the catch?](#whats-the-catch)

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
docker run -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -e TERM=$TERM -it --rm ubuntu bash -c '
  set -uex
  apt update
  apt install -y zsh git
  cd
  git clone https://github.com/romkatv/powerlevel10k.git
  echo "
    # Your prompt configuration goes here.
    POWERLEVEL9K_PROMPT_ON_NEWLINE=true
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(root_indicator dir_writable dir vcs)
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)
    source ~/powerlevel10k/powerlevel10k.zsh-theme" >~/.zshrc
  cd powerlevel10k
  zsh -i'
```

## How fast is it?

Powerlevel10k renders prompt about 50 times faster than powerlevel9k/master (stable version) and
about 15 times faster than powerlevel9k/next (beta version).

Here are benchmark results obtained with
[zsh-prompt-benchmark](https://github.com/romkatv/zsh-prompt-benchmark) on Intel i9-7900X
running Ubuntu 18.04.

| Theme               | /         | ~/nerd-fonts |
|---------------------|----------:|-------------:|
| powerlevel9k/master |    135 ms |       233 ms |
| powerlevel9k/next   |     27 ms |       107 ms |
| **powerlevel10k**   |  **2 ms** |     **6 ms** |
| naked zsh           |      1 ms |         1 ms |

Columns define the current directory where the prompt was rendered.

  * `/` -- root directory, not a git repo.
  * `~/nerd-fonts` -- [nerd-fonts](https://github.com/ryanoasis/nerd-fonts) git repo
    with 4k files.

Here's how the prompt looked like during benchmarking.

![](https://raw.githubusercontent.com/romkatv/powerlevel10k/master/prompt.png)

It was identical in Powerlevel10k and Powerlevel9k. Even though Powerlevel10k can dynamically
switch to async prompts, it wasn't happening here because latencies were low. Prompts with both
themes were essentially synchronous with every prompt having up-to-date git info.

_This table used to have another column for Linux kernel git repo, which is massive. It's
been removed because it's not a fair comparison. Powerlevel10k automatically detects that
fetching git status is slow and switches to async prompt generation, which allows it to
achieve 2 ms prompt latency but not all its prompt have up-to-date git info. Those that don't,
have vcs segment greyed out._

Configuration that was used:

```zsh
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir_writable dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs time custom_rprompt)

POWERLEVEL9K_MODE=nerdfont-complete
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_CUSTOM_RPROMPT=custom_rprompt
POWERLEVEL9K_ROOT_ICON=\\uF09CPOWERLEVEL9K_TIME_ICON=\\uF017
POWERLEVEL9K_CUSTOM_RPROMPT_ICON=\\uF005
POWERLEVEL9K_TIME_BACKGROUND=magenta
POWERLEVEL9K_CUSTOM_RPROMPT_BACKGROUND=blue
POWERLEVEL9K_STATUS_OK_BACKGROUND=grey53
POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=orange1
POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=black

function custom_rprompt() echo -E "hello world"

sleep 86400 &  # spawn two background jobs
sleep 86400 &
```

Here's the same benchmark for Windows Subsystem for Linux (WSL) with zsh running in the standard
Command Prompt (`cmd.exe`).


| Theme               | /         | ~/nerd-fonts |
|---------------------|----------:|-------------:|
| powerlevel9k/master |    313 ms |       693 ms |
| powerlevel9k/next   |    119 ms |       442 ms |
| **powerlevel10k**   | **16 ms** |    **19 ms** |
| naked zsh           |     16 ms |        16 ms |

The fastests results are probably limited by the key repeat rate.

Here's Raspberry Pie 3. I replaced [nerd-fonts](https://github.com/ryanoasis/nerd-fonts) repo with
[git](https://github.com/git/git) in this benchmark becase the former didn't fit on my SD card.
Git repo had 3.6k files, so about the same size. I set `POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=1`
to prevent Powerlevel10k from switching to async prompts. The default threshold is 0.05, or 50 ms,
after which Powerlevel10k will go async (git latency in ~/git was close to 100 ms, so above the
default 50 ms). Naturally, async is a good thing, so you shouldn't disable it in your configs. I
only did it to measure sync latency.

| Theme               | /         | ~/git      |
|---------------------|----------:|-----------:|
| powerlevel9k/master |    312 ms |     584 ms |
| **powerlevel10k**   | **15 ms** | **108 ms** |
| naked zsh           |      1 ms |       1 ms |

The `next` branch of Powerlevel9k didn't work on Raspberry Pie, so I couldn't benchmark it.

## What's the catch?

Really, there is no catch. It's literally the same prompt with the same flexibility
configuration format as Powerlevel9k. But **much faster**.

If you really need to know, here's where Powerlevel10k differs from Powerlevel9k:

  * Git prompt doesn't show tags and revisions. Open an issue if you need them.
  * By default only git vcs backend is enabled. If you need svn and hg, you'll need to set
    `POWERLEVEL9K_VCS_BACKENDS`. See [Extra configuration](#extra-configuration).
  * Fewer configuration options can be changed after the theme is loaded. For example, if you
    decide to change background color of some segment in the middle of an interactive session,
    it may not work.

## Known bugs

When a notification about an exiting job is displayed, prompt content doesn't get refreshed.
In Powerlevel9k it does. This could be fixed but the fix will add non-trivial complexity and
extra prompt latency.
