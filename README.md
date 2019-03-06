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
2. [Try it out](#try-it-out)
3. [How fast is it?](#how-fast-is-it)
4. [What's the catch?](#whats-the-catch)

## Installation and configuration

For installation and configuration instructions see
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k). Everything in there applies to
Powerlevel10k as well. Follow the official installation guide, make sure everything works
and you like the way prompt looks. Then simply replace Powerlevel9k with Powerlevel10k. Once
you restart zsh, your prompt will be faster. No configuration changes are needed.

Manual installation:

```zsh
git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc
```

Make sure to disable your current theme.

## Try it out

Try Powerlevel10k without making any changes to your setup. If you like it, see
[Installation and configuration](#installation-and-configuration) for how to make a permanent
switch.

### For existing Powerlevel9k users

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
  source ~/powerlevel10k/powerlevel10k.zsh-theme" >/tmp/powerlevel10k/.zshrc
ZDOTDIR=/tmp/powerlevel10k zsh
```

When you are done playing, `rm -rf /tmp/powerlevel10k` and exit zsh.

```zsh
git clone https://github.com/romkatv/powerlevel10k.git /tmp/powerlevel10k
source /tmp/powerlevel10k/powerlevel10k.zsh-theme
```

### Docker playground (Linux only)

You can try Powerlevel10k in Docker. Once you exit zsh, the image is deleted.

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

Powerlevel10k renders prompt about 10 times faster than powerlevel9k/master (stable version) and
about 5 times faster than powerlevel9k/next (beta version).

Here are benchmark results obtained with
[zsh-prompt-benchmark](https://github.com/romkatv/zsh-prompt-benchmark) on Intel i9-7900X
running Ubuntu 18.04.

| Theme                            | /         | ~/testrepo | ~/nerd-fonts | ~/linux    |
|----------------------------------|----------:|-----------:|-------------:|-----------:|
| powerlevel9k/master              |    135 ms |     207 ms |       234 ms |     338 ms |
| powerlevel9k/next                |     47 ms |     101 ms |       122 ms |     213 ms |
| powerlevel10k                    |     24 ms |      82 ms |       104 ms |     197 ms |
| **powerlevel10k with gitstatus** |  **2 ms** |  **5 ms** |    **6 ms** |  **126 ms** |
| naked zsh                        |      1 ms |       1 ms |         1 ms |       1 ms |

Columns define the current directory where the prompt was rendered.

  * `/` -- root directory, not a git repo.
  * `~/testrepo` -- a tiny git repo.
  * `~/nerd-fonts` -- [nerd-fonts](https://github.com/ryanoasis/nerd-fonts) git repo
    with 4k files.
  * `~/linux` -- [linux](https://github.com/torvalds/linux) git repo. Huge.

Here's how the prompt looked like (identical by design in Powerlevel9k and Powerlevel 10k):

![](https://raw.githubusercontent.com/romkatv/powerlevel10k/master/prompt.png)

Configuration that was used during benchmarking:

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

# Powerlevel10k extension to enable gitstatus. Has no effect on Powerlevel9k.
POWERLEVEL9K_VCS_STATUS_COMMAND=gitstatus_query_dir

function custom_rprompt() echo -E "hello world"
```

Here's the same benchmark for Windows Subsystem for Linux (WSL) with
zsh running in the standard Command Prompt (`cmd.exe`).


| Theme                            | /         | ~/testrepo | ~/nerd-fonts | ~/linux     |
|----------------------------------|----------:|-----------:|-------------:|------------:|
| powerlevel9k/master              |    313 ms |     531 ms |       693 ms |     5898 ms |
| powerlevel9k/next                |    119 ms |     278 ms |       442 ms |     5710 ms |
| powerlevel10k                    |     66 ms |     237 ms |       399 ms |     5569 ms |
| **powerlevel10k with gitstatus** | **22 ms** |  **30 ms** |    **30 ms** | **5098 ms** |
| naked zsh                        |     16 ms |      16 ms |        16 ms |       16 ms |

Here Powerlevel10k with [gitstatus](https://github.com/romkatv/gitstatus) has even bigger
advantage over Powerlevel9k and manages to render prompt with low latency.

However, every theme failed miserably on the humongous Linux kernel repo, showing prompt latency
over 5 seconds. This might be related to some sort of system cache that can fit indices of
smaller repos but not of Linux kernel. To work around this problem, you can instruct
[gitstatus](https://github.com/romkatv/gitstatus) to not scan dirty files on repos with over 4k
files in the index (see `GITSTATUS_DIRTY_MAX_INDEX_SIZE` in
[gitstatus docs](https://github.com/romkatv/gitstatus)). Linux kernel is the only repo in these
benchmarks that is over this threshold. Its prompt latency goes down to 32 ms but the prompt no
longer shows whether there are dirty (unstaged or untracked) files. It does helpfully indicate
with the color that there _might_ be such files.

## What's the catch?

Really, there is no catch. It's literally the same prompt with the same flexibility
configuration format as Powerlevel9k. But **much faster**.
