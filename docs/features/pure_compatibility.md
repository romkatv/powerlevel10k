# Pure compatibility

Powerlevel10k can produce the same prompt as [Pure](https://github.com/sindresorhus/pure). Type
`p10k configure` and select *Pure* style.

![Powerlevel10k Pure Style](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/pure-style.gif)

You can still use Powerlevel10k features such as [transient prompt](#transient-prompt) or
[instant prompt](#instant-prompt) when sporting Pure style.

To customize prompt, edit `~/.p10k.zsh`. Powerlevel10k doesn't recognize Pure configuration
parameters, so you'll need to use `POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3` instead of
`PURE_CMD_MAX_EXEC_TIME=3`, etc. All relevant parameters are in `~/.p10k.zsh`. This file has
plenty of comments to help you navigate through it.

*FAQ:* [What is the best prompt style in the configuration wizard?](
  #what-is-the-best-prompt-style-in-the-configuration-wizard)