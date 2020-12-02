# Configuration

## For new users

On the first run, Powerlevel10k [configuration wizard](#configuration-wizard) will ask you a few
questions and configure your prompt. If it doesn't trigger automatically, type `p10k configure`.
Configuration wizard creates `~/.p10k.zsh` based on your preferences. Additional prompt
customization can be done by editing this file. It has plenty of comments to help you navigate
through configuration options.

_FAQ_:

- [What is the best prompt style in the configuration wizard?](#what-is-the-best-prompt-style-in-the-configuration-wizard)
- [What do different symbols in Git status mean?](#what-do-different-symbols-in-git-status-mean)
- [How do I change the format of Git status?](#how-do-i-change-the-format-of-git-status)
- [How do I add username and/or hostname to prompt?](#how-do-i-add-username-and-or-hostname-to-prompt)
- [How do I change prompt colors?](#how-do-i-change-prompt-colors)
- [Why some prompt segments appear and disappear as I'm typing?](#why-some-prompt-segments-appear-and-disappear-as-im-typing)

_Troubleshooting_:

- [Question mark in prompt](#question-mark-in-prompt).
- [Icons, glyphs or powerline symbols don't render](#icons-glyphs-or-powerline-symbols-don-39-t-render).
- [Sub-pixel imperfections around powerline symbols](#sub-pixel-imperfections-around-powerline-symbols).
- [Directory is difficult to see in prompt when using Rainbow style](#directory-is-difficult-to-see-in-prompt-when-using-rainbow-style).

## For Powerlevel9k users

If you've been using Powerlevel9k before, **do not remove the configuration options**. Powerlevel10k
will pick them up and provide you with the same prompt UI you are used to. See
[Powerlevel9k compatibility](#powerlevel9k-compatibility).

_FAQ_:

- [I'm using Powerlevel9k with Oh My Zsh. How do I migrate?](#i-39-m-using-powerlevel9k-with-oh-my-zsh-how-do-i-migrate)
- [What is the relationship between Powerlevel9k and Powerlevel10k?](#what-is-the-relationship-between-powerlevel9k-and-powerlevel10k)
- [Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?](#does-powerlevel10k-always-render-exactly-the-same-prompt-as-powerlevel9k-given-the-same-config)

_Troubleshooting_: [Extra or missing spaces in prompt compared to Powerlevel9k](#extra-or-missing-spaces-in-prompt-compared-to-powerlevel9k).
