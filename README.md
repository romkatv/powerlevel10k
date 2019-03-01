# Powerlevel10k

Powerlevel10k is a theme for ZSH. It's a backward-compatible fork of
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k) with lower latency and better
prompt responsiveness.

If you like the look and feel of Powerlevel9k but feeling frustrated by the
slow prompt, simply replace your `powerlevel9k` theme with `powerlevel10k` and
enjoy responsive shell like it's 80's again!

Powerlevel10k uses the same configuration options as Powerlevel9k and produces the
same results. It's simply faster. There is no catch.

If you are on Linux or WSL, consider enabling [gitstatus](https://github.com/romkatv/gitstatus)
plugin for massive performance improvement in vcs/prompt segment. It works well with Powerlevel10k.

## Installation & Configuration

For installation and configuration instructions, see
[Powerlevel9k](https://github.com/bhilburn/powerlevel9k). Everything in there applies to
Powerlevel10k as well. Follow the installation guide, make sure everything works and you like
the way prompt looks. Then simply replace `powerlevel9k.zsh-theme` with the one from Powerlevel10k
([link](https://github.com/romkatv/powerlevel10k/blob/master/powerlevel9k.zsh-theme)). Or replace
the whole `powerlevel9k` directory to gain the ability to `git pull` updates in the future. Once
you restart zsh, your prompt will be faster.

**Do not load both Powerlevel9k and Powerlevel10k themes at the same time. Variable name
clashes will cause mayhem. Source either one or the other. Consider Powerlevel10k
a patched fork of Powerlevel9k, which it is.**

## How fast is it?

Powerlevel10k with [gitstatus](https://github.com/romkatv/gitstatus) renders prompt 5+ times
faster than Powerlevel9k. In some cases it can be over 10 times faster. When using Linux,
you should expect less than 50ms prompt latency in most cases, about 100ms in large git
repos and 200ms in huge repos such as Linux kernel. To get comfortable upper bound on
latency in any repo, set `GITSTATUS_DIRTY_MAX_INDEX_SIZE=4096`. It'll disable dirty file
scanning in repos with over 4k files. This should give you under 100ms prompt latency
everywhere.

## What's the catch?

Really, there is no catch. It's the same prompt with the same flexibility and literally the
same configuration as Powerlevel9k but **much faster**.
