# Current directory that just works

The current working directory is perhaps the most important prompt segment. Powerlevel10k goes to
great length to highlight its important parts and to truncate it with the least loss of information
when horizontal space gets scarce.

![Powerlevel10k Directory Truncation](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/directory-truncation.gif)

When the full directory doesn't fit, the leftmost segment gets truncated to its shortest unique
prefix. In the screencast, `~/work` becomes `~/wo`. It couldn't be truncated to `~/w` because it
would be ambiguous (there was `~/wireguard` when the session was recorded). The next segment --
`projects` -- turns into `p` as there was nothing else that started with `p` in `~/work/`.

Directory segments are shown in one of three colors:

- Truncated segments are bleak.
- Important segments are bright and never truncated. These include the first and the last segment,
  roots of Git repositories, etc.
- Regular segments (not truncated but can be) use in-between color.

_Tip_: If you copy-paste a truncated directory and hit _TAB_, it'll complete to the original.

_Troubleshooting_: [Directory is difficult to see in prompt when using Rainbow style.](../troubleshooting.md#directory-is-difficult-to-see-in-prompt-when-using-rainbow-style)
