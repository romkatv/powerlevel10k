# Powerlevel10k

Powerlevel10k is a theme for ZSH. It's a backward-compatible fork of
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k) with lower latency and better
prompt responsiveness.

If you like the looks of Powerlevel9k but feeling frustrated by its slow prompt,
simply replace your `powerlevel9k` theme with `powerlevel10k` and enjoy responsive
shell like it's 80's again!

Powerlevel10k uses the same configuration options as Powerlevel9k and produces the
same results. It's simply faster. There is no catch.

If you are on Linux or WSL, consider enabling [gitstatus](https://github.com/romkatv/gitstatus)
plugin for additional performance improvement in the vcs/prompt segment.

## Installation & Configuration

For installation and configuration instructions see
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k). Everything in there applies to
Powerlevel10k as well. Follow the official installation guide, make sure everything works
and you like the way prompt looks. Then simply replace the content of your `powerlevel9k`
directory with Powerlevel10k. Once you restart zsh, your prompt will be faster. No
configuration changes are needed.

If you are using oh-my-zsh, here's how you can replace Powerlevel9k with Powerlevel10k.

```zsh
# Delete the original powerlevel9k theme.
rm -rf ~/.oh-my-zsh/custom/themes/powerlevel9k
# Put powerlevel10k in its place.
git clone git@github.com:romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
```

Adjust these commands based on where your `powerlevel9k` directory is.

Alternatively, you can place `Powerlevel10k` in `powerlevel10k` directory and modify
the theme name in your `.zshrc`. **However, do not load both Powerlevel9k and Powerlevel10k
themes at the same time. Variable name clashes will cause mayhem. You can source either
one or the other. Consider Powerlevel10k a patched fork of Powerlevel9k, which it is.**

## How fast is it?

Powerlevel10k with [gitstatus](https://github.com/romkatv/gitstatus) renders prompt about
10 times faster than powerlevel9k/master (stable version) and about 5 times faster than
powerlevel9k/next (beta version). Powerlevel10k is faster than Powerlevel9k even without
[gitstatus](https://github.com/romkatv/gitstatus) but the difference isn't as dramatic.

Here's are benchmark results obtained with
[zsh-prompt-benchmark](https://github.com/romkatv/zsh-prompt-benchmark) on Intel i9-7900X
running Ubuntu 18.04.

| Theme                            | /         | ~/testrepo | ~/nerd-fonts | ~/linux    |
|----------------------------------|----------:|-----------:|-------------:|-----------:|
| powerlevel9k/master              |    135 ms |     207 ms |       234 ms |     326 ms |
| powerlevel9k/next                |     47 ms |     101 ms |       122 ms |     213 ms |
| powerlevel10k                    |     24 ms |      82 ms |       104 ms |     197 ms |
| **powerlevel10k with gitstatus** |  **9 ms** |  **11 ms** |    **27 ms** |  **71 ms** |
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

## What's the catch?

Really, there is no catch. It's literally the same prompt with the same flexibility
configuration format as Powerlevel9k. But **much faster**.
