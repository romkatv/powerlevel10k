# Troubleshooting

## Question mark in prompt

If it looks like a regular `?`, that's normal. It means you have untracked files in the current Git
repository. Type `git status` to see these files. You can change this symbol or disable the display
of untracked files altogether. Search for `untracked files` in `~/.p10k.zsh`.

_FAQ_: [What do different symbols in Git status mean?](#what-do-different-symbols-in-git-status-mean)

You can also get a weird-looking question mark in your prompt if your terminal's font is missing
some glyphs. See [icons, glyphs or powerline symbols don't render](#icons-glyphs-or-powerline-symbols-don-39-t-render).

## Icons, glyphs or powerline symbols don't render

Restart your terminal, [install the recommended font](#recommended-font-meslo-nerd-font-patched-for-powerlevel10k)
and run `p10k configure`.

## Sub-pixel imperfections around powerline symbols

![Powerline Prompt Imperfections](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/powerline-imperfections.png)

There are three imperfections on the screenshot. From left to right:

1. A thin blue line (a sub-pixel gap) between the content of a prompt segment and the following
   powerline connection.
1. Incorrect alignment of a powerline connection and the following prompt segment. The connection
   appears shifted to the right.
1. A thin red line below a powerline connection. The connection appears shifted up.

Zsh themes don't have down-to-pixel control over the terminal content. Everything you see on the
screen is made of monospace characters. A white powerline prompt segment is made of text on white
background followed by U+E0B0 (a right-pointing triangle).

![Powerline Prompt Imperfections](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/powerline-anatomy.png)

If Powerlevel10k prompt has imperfections around powerline symbols, you'll see exactly the same
imperfections with all powerline themes (Agnoster, Powerlevel9k, Powerline, etc.)

There are several things you can try to deal with these imperfections:

- Try [the recommended font](#recommended-font-meslo-nerd-font-patched-for-powerlevel10k). If you are already using
  it, switching to another font may help but is unlikely.
- Change terminal font size one point up or down. For example, in iTerm2 powerline prompt looks
  perfect at font sizes 11 and 13 but breaks down at 12.
- Enable builtin powerline glyphs in terminal settings if your terminal supports it (iTerm2 does).
- Change font hinting and/or anti-aliasing mode in the terminal settings.
- Shift all text one pixel up/down/left/right if your terminal has an option to do so.
- Try a different terminal.

A more radical solution is to switch to prompt style without background. Type `p10k configure` and
select _Lean_. This style has a modern lightweight look. As a bonus, it doesn't suffer from
rendering imperfections that afflict powerline-style prompt.

## Error: character not in range

Type `echo '\u276F'`. If you get an error saying "zsh: character not in range", your locale
doesn't support UTF-8. You need to fix it. If you are running Zsh over SSH, see
[this](https://github.com/romkatv/powerlevel10k/issues/153#issuecomment-518347833). If you are
running Zsh locally, Google "set UTF-8 locale in _your OS_".

## Cursor is in the wrong place

Type `echo '\u276F'`. If you get an error saying "zsh: character not in range", see the
[previous section](#error-character-not-in-range).

If the `echo` command prints `❯` but the cursor is still in the wrong place, install
[the recommended font](#recommended-font-meslo-nerd-font-patched-for-powerlevel10k) and run
`p10k configure`.

If this doesn't help, add `unset ZLE_RPROMPT_INDENT` at the bottom of `~/.zshrc`.

Still having issues? Run the following command to diagnose the problem:

```zsh
() {
  emulate -L zsh
  setopt err_return no_unset
  local text
  print -rl -- 'Select a part of your prompt from the terminal window and paste it below.' ''
  read -r '?Prompt: ' text
  local -i len=${(m)#text}
  local frame="+-${(pl.$len..-.):-}-+"
  print -lr -- $frame "| $text |" $frame
}
```

### If the prompt line aligns with the frame

```text
+------------------------------+
| romka@adam ✓ ~/powerlevel10k |
+------------------------------+
```

If the output of the command is aligned for every part of your prompt (left and right), this
indicates a bug in the theme or your config. Use this command to diagnose it:

```zsh
print -rl -- ${(eq+)PROMPT} ${(eq+)RPROMPT}
```

Look for `%{...%}` and backslash escapes in the output. If there are any, they are the likely
culprits. Open an issue if you get stuck.

### If the prompt line is longer than the frame

```text
+-----------------------------+
| romka@adam ✓ ~/powerlevel10k |
+-----------------------------+
```

This is usually caused by a terminal bug or misconfiguration that makes it print ambiguous-width
characters as double-width instead of single width. For example,
[this issue](https://github.com/romkatv/powerlevel10k/issues/165).

### If the prompt line is shorter than the frame and is mangled

```text
+------------------------------+
| romka@adam ✓~/powerlevel10k |
+------------------------------+
```

Note that this prompt is different from the original as it's missing a space after the check mark.

This can be caused by a low-level bug in macOS. See
[this issue](https://github.com/romkatv/powerlevel10k/issues/241).

This can also happen if prompt contains glyphs designated as "wide" in the Unicode standard and your
terminal incorrectly displays them as non-wide. Terminals suffering from this limitation include
Konsole, Hyper and the integrated VSCode Terminal. The solution is to use a different terminal or
remove all wide glyphs from prompt.

### If the prompt line is shorter than the frame and is not mangled

```text
+--------------------------------+
| romka@adam ✓ ~/powerlevel10k |
+--------------------------------+
```

This can be caused by misconfigured locale. See
[this issue](https://github.com/romkatv/powerlevel10k/issues/251).

## Prompt wrapping around in a weird way

See [cursor is in the wrong place](#cursor-is-in-the-wrong-place).

## Right prompt is in the wrong place

See [cursor is in the wrong place](#cursor-is-in-the-wrong-place).

## Configuration wizard runs automatically every time Zsh is started

When Powerlevel10k starts, it automatically runs `p10k configure` if no `POWERLEVEL9K_*`
parameters are defined. Based on your prompt style choices, the configuration wizard creates
`~/.p10k.zsh` with a bunch of `POWERLEVEL9K_*` parameters in it and adds a line to `~/.zshrc` to
source this file. The next time you start Zsh, the configuration wizard shouldn't run automatically.
If it does, this means the evaluation of `~/.zshrc` terminates prematurely before it reaches the
line that sources `~/.p10k.zsh`. This most often happens due to syntax errors in `~/.zshrc`. These
errors get hidden by the configuration wizard screen, so you don't notice them. When you exit
configuration wizard, look for error messages. You can also use
`POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true zsh` to start Zsh without automatically running the
configuration wizard. Once you can see the errors, fix `~/.zshrc` to get rid of them.

## Some prompt styles are missing from the configuration wizard

If Zsh version is below 5.7.1 or `COLORTERM` environment variable is neither `24bit` nor
`truecolor`, configuration wizard won't offer Pure style with Snazzy color scheme. _Fix_: Install
Zsh >= 5.7.1 and use a terminal with truecolor support. Verify with `print -P '%F{#ff0000}red%f'`.

If the terminal can display fewer than 256 colors, configuration wizard preselects Lean style with
8 colors. All other styles require at least 256 colors. _Fix_: Use a terminal with 256 color support
and make sure that `TERM` environment variable is set correctly. Verify with
`print $terminfo[colors]`.

If there is no UTF-8 locale on the system, configuration wizard won't offer prompt styles that use
Unicode characters. _Fix_: Install a UTF-8 locale. Verify with `locale -a`.

When a UTF-8 locale is available, the first few questions asked by the configuration wizard assess
capabilities of the terminal font. If your answers indicate that some glyphs don't render correctly,
configuration wizard won't offer prompt styles that use them. _Fix_: Restart your terminal and
install [the recommended font](#recommended-font-meslo-nerd-font-patched-for-powerlevel10k). Verify by running
`p10k configure` and checking that all glyphs render correctly.

## Cannot install the recommended font

Once you download [the recommended font](#recommended-font-meslo-nerd-font-patched-for-powerlevel10k),
you can install it just like any other font. Google "how to install fonts on _your OS_".

## Extra or missing spaces in prompt compared to Powerlevel9k

tl;dr: Add `ZLE_RPROMPT_INDENT=0` and `POWERLEVEL9K_LEGACY_ICON_SPACING=true` to `~/.zshrc` to get
the same prompt spacing as in Powerlevel9k.

When using Powerlevel10k with a Powerlevel9k config, you might get additional spaces in prompt here
and there. These come in two flavors.

### Extra space without background on the right side of right prompt

tl;dr: Add `ZLE_RPROMPT_INDENT=0` to `~/.zshrc` to get rid of that space.

From [Zsh documentation](http://zsh.sourceforge.net/Doc/Release/Parameters.html#index-ZLE_005fRPROMPT_005fINDENT):

> `ZLE_RPROMPT_INDENT <S>`
>
> If set, used to give the indentation between the right hand side of the right prompt in the line
> editor as given by `RPS1` or `RPROMPT` and the right hand side of the screen. If not set, the
> value `1` is used.
>
> Typically this will be used to set the value to `0` so that the prompt appears flush with the
> right hand side of the screen.

Powerlevel10k respects this parameter. If you set `ZLE_RPROMPT_INDENT=1` (or leave it unset, which
is the same thing as setting it to `1`), you'll get an empty space to the right of right prompt. If
you set `ZLE_RPROMPT_INDENT=0`, your prompt will go to the edge of the terminal. This is how it
works in every theme except Powerlevel9k.

![ZLE_RPROMPT_INDENT: Powerlevel10k vs Powerlevel9k](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/p9k-vs-p10k-zle-rprompt-indent.png)

Powerlevel9k issue: [powerlevel9k#1292](https://github.com/Powerlevel9k/powerlevel9k/issues/1292).
It's been fixed in the development branch of Powerlevel9k but the fix hasn't yet made it to
`master`.

Add `ZLE_RPROMPT_INDENT=0` to `~/.zshrc` to get the same spacing on the right edge of prompt as in
Powerlevel9k.

_Note:_ Several versions of Zsh have bugs that get triggered when you set `ZLE_RPROMPT_INDENT=0`.
Powerlevel10k can work around these bugs when using powerline prompt style. If you notice visual
artifacts in prompt, or wrong cursor position, try removing `ZLE_RPROMPT_INDENT` from `~/.zshrc`.

### Extra or missing spaces around icons

tl;dr: Add `POWERLEVEL9K_LEGACY_ICON_SPACING=true` to `~/.zshrc` to get the same spacing around
icons as in Powerlevel9k.

Spacing around icons in Powerlevel9k is inconsistent.

![ZLE_RPROMPT_INDENT: Powerlevel10k vs Powerlevel9k](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/p9k-vs-p10k-icon-spacing.png)

This inconsistency is a constant source of annoyance, so it was fixed in Powerlevel10k. You can add
`POWERLEVEL9K_LEGACY_ICON_SPACING=true` to `~/.zshrc` to get the same spacing around icons as in
Powerlevel9k.

_Note:_ It's not a good idea to define `POWERLEVEL9K_LEGACY_ICON_SPACING` when using
`p10k configure`.

## Weird things happen after typing `source ~/.zshrc`

It's almost always a bad idea to run `source ~/.zshrc`, whether you are using Powerlevel10k or not.
This command may result in random errors, misbehaving code and progressive slowdown of Zsh.

If you've made changes to `~/.zshrc` or to files sourced by it, restart Zsh to apply them. The most
reliable way to do this is to type `exit` and then start a new Zsh session. You can also use
`exec zsh`. While not exactly equivalent to complete Zsh restart, this command is much more reliable
than `source ~/.zshrc`.

## Transient prompt stops working after some time

See [weird things happen after typing `source ~/.zshrc`](#weird-things-happen-after-typing-source-zshrc).

## Cannot make Powerlevel10k work with my plugin manager

If the [installation instructions](#installation) didn't work for you, try disabling your current
theme (so that you end up with no theme) and then installing Powerlevel10k manually.

First: Disable the current theme in your framework / plugin manager.

- **oh-my-zsh:** Open `~/.zshrc` and remove the line that sets `ZSH_THEME`. It might look like this:
  `ZSH_THEME="powerlevel9k/powerlevel9k"`.
- **zplug:** Open `~/.zshrc` and remove the `zplug` command that refers to your current theme. For
  example, if you are currently using Powerlevel9k, look for
  `zplug bhilburn/powerlevel9k, use:powerlevel9k.zsh-theme`.
- **prezto:** Open `~/.zpreztorc` and put `zstyle :prezto:module:prompt theme off` in it. Remove
  any other command that sets `theme` such as `zstyle :prezto:module:prompt theme powerlevel9k`.
- **antigen:** Open `~/.zshrc` and remove the line that sets `antigen theme`. It might look like
  this: `antigen theme powerlevel9k/powerlevel9k`.

```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
```

Second: Install Powerlevel10k manually 👉

This method of installation won't make anything slower or otherwise sub-par.

## Directory is difficult to see in prompt when using Rainbow style

In Rainbow style the current working directory is shown with bright white text on blue background.
The white is fixed and always looks the same but the appearance of "blue" is defined by your
terminal color palette. If it's very light, it may be difficult to see white text on it.

There are several ways to fix this.

- Type `p10k configure` and choose a more readable prompt style.
- [Change terminal color palette](#change-the-color-palette-used-by-your-terminal). Try Tango Dark
  or Solarized Dark, or change just the "blue" color.
- [Change directory background and/or foreground color](#set-colors-through-powerlevel10k-configuration-parameters).
  The parameters you are looking for are called `POWERLEVEL9K_DIR_BACKGROUND`,
  `POWERLEVEL9K_DIR_FOREGROUND`, `POWERLEVEL9K_DIR_SHORTENED_FOREGROUND`,
  `POWERLEVEL9K_DIR_ANCHOR_FOREGROUND` and `POWERLEVEL9K_DIR_ANCHOR_BOLD`. You can find them in
  in `~/.p10k.zsh`.

## Horrific mess when resizing terminal window

When you resize terminal window horizontally back and forth a few times, you might see this ugly
picture.

![Powerlevel10k Resizing Mess](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/resizing-mess.png)

tl;dr: This is a bug in Zsh that isn't specific to Powerlevel10k. See [mitigation](#mitigation).

### Zsh bug

This issue is caused by a bug in Zsh that gets triggered when the vertical distance between the
start of the current prompt and the cursor (henceforth `VD`) changes when the terminal window is
resized. This bug is not specific to Powerlevel10k.

When a terminal window gets shrunk horizontally, there are two ways for a terminal to handle long
lines that no longer fit: _reflow_ or _truncate_.

Terminal content before shrinking:

![Terminal Content Before Shrinking](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/resize-original.png)

Terminal reflows text when shrinking:

![Terminal Reflows Text When Shrinking](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/resize-reflow.png)

Terminal truncates text when shrinking:

![Terminal Truncates Text When Shrinking](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/resize-truncate.png)

Reflowing strategy can change the height of terminal content. If such content happens to be between
the start of the current prompt and the cursor, Zsh will print prompt on the wrong line. Truncation
strategy never changes the height of terminal content, so it doesn't trigger this bug in Zsh.

Let's see how the bug plays out in slow motion. We'll start by launching `zsh -df` and pasting
the following code:

```zsh
function pause() { read -s }
functions -M pause 0

reset
print -l {1..3}
setopt prompt_subst
PROMPT=$'${$((pause()))+}left>${(pl.$((COLUMNS-12))..-.)}<right\n> '
```

When `PROMPT` gets expanded, it calls `pause` to let us observe the state of the terminal. Here's
the initial state:

![Zsh Resizing Bug 1](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/resize-bug-1.png)

Zsh keeps track of the cursor position relative to the start of the current prompt. In this case it
knows that the cursor is one line below. When we shrink the terminal window, it looks like this:

![Zsh Resizing Bug 2](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/resize-bug-2.png)

At this point the terminal sends `SIGWINCH` to Zsh to notify it about changes in the terminal
dimensions. Note that this signal is sent _after_ the content of the terminal has been reflown.

When Zsh receives `SIGWINCH`, it attempts to erase the current prompt and print it anew. It goes to
the position where it _thinks_ the current prompt is -- one line above the cursor (!) -- erases all
terminal content that follows and prints reexpanded prompt there. However, after resizing prompt is
no longer one line above the cursor. It's two lines above! Zsh ends up printing new prompt one line
too low.

![Zsh Resizing Bug 3](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/resize-bug-3.png)

In this case we ended up with unwanted junk content because `VD` has _increased_. When you make
terminal window wider, `VD` can also _decrease_, which would result in the new prompt being printed
higher than intended, potentially erasing useful content in the process.

Here are a few more examples where shrinking terminal window increased `VD`.

Simple one-line left prompt with right prompt. No `prompt_subst`. Note that the cursor is below the
prompt line (hit _ESC-ENTER_ to get it there).

![Zsh Prompt That Breaks on Terminal Shrinking 1](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/resize-breakable-1.png)

Simple one-line left prompt. No `prompt_subst`, no right prompt. Here `VD` is bound to increase
upon terminal shrinking due to the command line wrapping around.

![Zsh Prompt That Breaks on Terminal Shrinking 2](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/resize-breakable-2.png)

### Zsh patch

The bug described above has been partially fixed (only for some terminals) in [this branch](https://github.com/romkatv/zsh/tree/fix-winchanged). The idea behind the fix is to use `sc` (save
cursor) terminal capability before printing prompt and `rc` (restore cursor) to move cursor back
to the original position when prompt needs to be refreshed.

The patch works only on terminals that reflow saved cursor position together with text when the
terminal window is resized. The patch has no observable effect on terminals that don't reflow text
on resize (both patched and unpatched Zsh behave correctly) and on terminals that reflow text but
not saved cursor position (both patched and unpatched Zsh redraw prompt at the same incorrect
position). In other words, the patch fixes the resizing issue on some terminals while keeping the
behavior unchanged on others.

There are two alternative approaches to fixing the bug that may seem to work at first glance but in
fact don't:

- Instead of `sc`, use `u7` terminal capability to query the current cursor position and then `cup`
  to go back to it. This doesn't work because the absolute position of the start of the current
  prompt changes when text gets reflown.
- Recompute `VD` based on new terminal dimensions before attempting to refresh prompt. This doesn't
  work because Zsh doesn't know whether terminal reflows text or truncates it. If Zsh could somehow
  know that the terminal reflows text, this approach still wouldn't work on terminals that
  continuously reflow text and rapid-fire `SIGWINCH` when the window is being resized. In such
  environment real terminal dimensions go out of sync with what Zsh thinks the dimensions are.

There is no ETA for the patch making its way into upstream Zsh. See [discussion](https://www.zsh.org/mla/workers//2019/msg00561.html).

### Mitigation

There are a few mitigation options for this issue.

- Apply [the patch](#zsh-patch) and [rebuild Zsh from source](https://github.com/zsh-users/zsh/blob/master/INSTALL). It won't help if you are using Alacritty,
  Kitty or some other terminal that reflows text on resize but doesn't reflow saved cursor position.
  On such terminals the patch will have no visible effect.
- Disable text reflowing on window resize in terminal settings. If your terminal doesn't have this
  setting, try a different terminal.
- Avoid long lines between the start of prompt and cursor.
  1. Disable ruler with `POWERLEVEL9K_SHOW_RULER=false`.
  2. Disable prompt connection with `POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '`.
  3. Disable right frame with `POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=''`,
     `POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=''` and
     `POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=''`.
  4. Set `POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()`. Right prompt on the last prompt line will cause
     resizing issues only when the cursor is below it. This isn't very common, so you might want to
     keep some elements in `POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS` provided that none of them are
     succeeded by `newline`.

## Icons cut off in Konsole

When using Konsole with a non-monospace font, icons may be cut off on the right side. Here
"non-monospace" refers to any font with glyphs wider than a single column, or wider than two columns
for glyphs designated as "wide" in the Unicode standard.

![Icons cut off in Konsole](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/konsole-non-monospace-font.png)

The last line on the screenshot shows a cut off Arch Linux logo.

There are several mitigation options for this issue.

```zsh
typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='${P9K_CONTENT} '  # extra space at the end
```

```zsh
typeset -g POWERLEVEL9K_LINUX_ARCH_ICON='Arch'  # plain "Arch" in place of a logo
```
1. Use a different terminal. Konsole is the only terminal that exhibits this behavior.
2. Use a monospace font.
3. Manually add an extra space after the icon that gets cut off. For example, if the content of
   `os_icon` prompt segment gets cut off, open `~/.p10k.zsh`, search for
   `POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION` and change it as follows 👉:
4. Use a different icon that is monospace. For example, if Arch Linux logo gets cut off, add
   the following parameter to `~/.p10k.zsh` 👉:
5. Disable the display of the icon that gets cut off. For example, if the content of
   `os_icon` prompt segment gets cut off, open `~/.p10k.zsh` and remove `os_icon` from
   `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS` and `POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS`.

_Note_: [Non-monospace fonts are not officially supported by Konsole](https://bugs.kde.org/show_bug.cgi?id=418553#c5).

## Arch Linux logo has a dot in the bottom right corner

![Arch Linux Logo with a dot](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/arch-linux-logo-dot.png)

Some fonts have this incorrect dotted icon in bold typeface. There are two ways to fix this issue.

```zsh
typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='${P9K_CONTENT}'  # not bold
```

1. Use a font with a correct Arch Linux logo in bold typeface. For example,
   [the recommended Powerlevel10k font](#recommended-font-meslo-nerd-font-patched-for-powerlevel10k).
2. Display the icon in regular (non-bold) typeface. To do this, open `~/.p10k.zsh`, search for
   `POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION` and remove `%B` from its value.
