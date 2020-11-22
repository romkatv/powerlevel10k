# Instant prompt

If your `~/.zshrc` loads many plugins, or perhaps just a few slow ones
(for example, [pyenv](https://github.com/pyenv/pyenv) or [nvm](https://github.com/nvm-sh/nvm)), you
may have noticed that it takes some time for Zsh to start.

![Powerlevel10k No Instant Prompt](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/no-instant-prompt.gif)

Powerlevel10k can remove Zsh startup lag **even if it's not caused by a theme**.

![Powerlevel10k Instant Prompt](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/instant-prompt.gif)

This feature is called _Instant Prompt_. You need to explicitly enable it through `p10k configure`
or [manually](../faq.md#how-do-i-enable-instant-prompt). It does what it says on the tin -- prints prompt
instantly upon Zsh startup allowing you to start typing while plugins are still loading.

Other themes _increase_ Zsh startup lag -- some by a lot, others by a just a little. Powerlevel10k
_removes_ it outright.

_FAQ:_ [How do I enable instant prompt?](../faq.md#how-do-i-enable-instant-prompt)
