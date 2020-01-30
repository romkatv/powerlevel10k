# Powerlevel10k
[![Gitter](https://badges.gitter.im/powerlevel10k/community.svg)](https://gitter.im/powerlevel10k/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Powerlevel10k is a theme for ZSH. It emphasizes [speed](#uncompromising-performance),
[flexibility](#extremely-customizable) and [out-of-the-box experience](#configuration-wizard).
Powerlevel10k is committed to being best-in-class in each of these categories. If you ever consider
switching to another theme because Powerlevel10k is not fast enough, not flexible enough or fails
to Just Work, please file an issue.

![Powerlevel10k](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/prompt-styles.png)

To see what Powerlevel10k is about, scroll through [features](#features).

Powerlevel9k users, go [here](#powerlevel9k-compatibility).

Ready to give Powerlevel10k a try?

1. Install [the recommended font](#meslo-nerd-font-patched-for-powerlevel10k). *Optional but highly
   recommended.*
1. Install Powerlevel10k for your plugin manager.
   - [Manual](#manual) 👈 **choose this if confused or uncertain**
   - [Oh My Zsh](#oh-my-zsh)
   - [Prezto](#prezto)
   - [Zim](#zim)
   - [Antigen](#antigen)
   - [Zplug](#zplug)
   - [Zgen](#zgen)
   - [Antibody](#antibody)
   - [Zplugin](#zplugin)
1. Restart Zsh.
1. Type `p10k configure` if the configuration wizard doesn't start automatically.

## Features

### Configuration wizard

Type `p10k configure` to access the builtin configuration wizard right from your terminal.

![Powerlevel10k Configuration Wizard](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/configuration-wizard.gif)

All styles except [Pure](#pure-compatibility) are functionally equivalent. They display the same
information and differ only in presentation.

Configuration wizard creates `~/.p10k.zsh` based on your preferences. Additional prompt
customization can be done by editing this file. It has many comments to help you navigate through
configuration options.

Tip: Install [the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k) before
running `p10k configure`.

### Uncompromising performance

When you hit *ENTER*, the next prompt appears instantly. With Powerlevel10k there is no prompt lag.
If you install Cygwin on Raspberry Pi, `cd` into a Linux Git repository and activate enough prompt
segments to fill four prompt lines on both sides of the screen... wait, that's just crazy and no
one ever does that. Probably impossible, too. The point is, Powerlevel10k prompt is always fast, no
matter what you do!

![Powerlevel10k Performance](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/performance.gif)

Note how the effect of every command is instantly reflected by the very next prompt.

| Command                       | Prompt Indicator | Meaning                                                               |
|-------------------------------|:----------------:|----------------------------------------------------------------------:|
| `timew start hack linux`      | `🛡️ hack linux`  | time tracking enabled in [timewarrior](https://timewarrior.net/)      |
| `touch x y`                   | `?2`             | 2 untracked files in the Git repo                                     |
| `rm COPYING`                  | `!1`             | 1 unstaged change in the Git repo                                     |
| `echo 2.7.3 >.python-version` | `🐍 2.7.3`       | the current python version in [pyenv](https://github.com/pyenv/pyenv) |

Other Zsh themes capable of displaying the same information either produce prompt lag or print
prompt that doesn't reflect the current state of the system and then refresh it later. With
Powerlevel10k you get fast prompt *and* up-to-date information.

### Powerlevel9k compatibility

Powerlevel10k understands all [Powerlevel9k](https://github.com/Powerlevel9k/powerlevel9k)
configuration parameters.

![Powerlevel10k Compatibility with 9k](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/9k-compatibility.gif)

If you are currently using Powerlevel9k, you can switch to Powerlevel10k in just a few seconds.
All your `POWERLEVEL9K` configuration parameters will still work. Prompt will look the same as
before ([almost](
  #does-powerlevel10k-always-render-exactly-the-same-prompt-as-powerlevel9k-given-the-same-config))
but it will be [much faster](#uncompromising-performance) ([certainly](#is-it-really-fast)).

FAQ: [I'm using Powerlevel9k with Oh My Zsh. How do I migrate?](
  #im-using-powerlevel9k-with-oh-my-zsh-how-do-i-migrate)

### Pure compatibility

Powerlevel10k can produce the same prompt as [Pure](https://github.com/sindresorhus/pure). Type
`p10k configure` and select *Pure* style.

![Powerlevel10k Pure Style](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/pure-style.gif)

You can still use Powerlevel10k features such as [Transient Prompt](#transient-prompt) or
[Instant Prompt](#instant-prompt) when sporting Pure style.

To customize prompt, edit `~/.p10k.zsh`. Powerlevel10k doesn't recognize Pure configuration
parameters, so you need to use `POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3` instead of
`PURE_CMD_MAX_EXEC_TIME=3`, etc. All relevant parameters are in the config.

### <a name='what-is-instant-prompt'></a>Instant prompt

If your `~/.zshrc` loads many plugins, or perhaps just a few slow ones (pyenv and nvm are the usual
suspects), you may have noticed that it takes some time for Zsh to start.

![Powerlevel10k No Instant Prompt](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/no-instant-prompt.gif)

Powerlevel10k can remove Zsh startup lag *even if it's not caused by a theme*.

![Powerlevel10k Instant Prompt](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/instant-prompt.gif)

This feature is called *Instant Prompt*. You need to explicitly enable it through `p10k configure`
or [manually](#what-is-instant-prompt). It does what it says on the tin -- prints prompt instantly
upon Zsh startup allowing you to start typing while plugins are still loading.

Other themes *increase* Zsh startup lag -- some by a lot, others by a just a little. Powerlevel10k
*removes* it outright.

For caveats and details, see [FAQ](#how-do-i-enable-instant-prompt).

### Show on command

The behavior of some commands depends on global environment. For example, `kubectl run ...` runs an
image on the cluster defined by the current kubernetes context. If you frequently change context
between "prod" and "testing", you might want to display the current context in Zsh prompt. If you do
likewise for AWS, Azure and Google Cloud credentials, prompt will get pretty crowded.

Enter *Show On Command*. This feature makes prompt segments appear only when they are relevant to
the command you are currently typing.

![Powerlevel10k Show On Command](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/show-on-command.gif)

Configs created by `p10k configure` enable Show On Command for several prompt segments by default.
Here's the relevant parameter for kubernetes context:

```zsh
# Show prompt segment "kubecontext" only when the command you are typing
# invokes kubectl, helm, kubens, kubectx or oc.
typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc'
```

To customize when different prompt segments are shown, open `~/.p10k.zsh`, search for
`SHOW_ON_COMMAND` and either remove these parameters to display affected segments unconditionally,
or change their values.

### Transient prompt

When *Transient Prompt* is enabled through `p10k configure`, Powerlevel10k will trim down every
prompt when accepting a command line.

![Powerlevel10k Show On Command](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/transient-prompt.gif)

Transient Prompt makes it much easier to copy-paste series of commands from the terminal scrollback.

Tip: If you enable Transient Prompt, take advantage of two-line prompt. You'll get the benefit of
extra space for typing commands without the usual drawback of reduced scrollback density.

### Current directory that just works

The current working directory is perhaps the most important prompt segment. Powerlevel10k goes to
great length to highlight its important parts and to truncate it with the least loss of information.

![Powerlevel10k Directory Truncation](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/directory-truncation.gif)

When the full directory doesn't fit, the leftmost segment gets truncated to its shortest unique
prefix. In the screencast, `~/work` becomes `~/wo`. It couldn't be truncated to `~/w` because it
would be ambiguous (there was `~/wireguard` when the session was recorded). The next segment --
`projects` -- turns into `p` as there was nothing else that started with `p` in `~/work`.

Directory segments are shown in one of three colors:

- Truncated segments are bleak.
- Important segments are bright and never truncated. These include the first and the last segment,
  roots of Git repositories, etc.
- Regular segments (not truncated but can be) use in-between color.

Tip: If you copy-paste a truncated directory and hit *TAB*, it'll complete to the original.

### Extremely customizable

Powerlevel10k can be configured to look like any other Zsh theme.

![Powerlevel10k Other Theme Emulation](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/other-theme-emulation.gif)

[Pure](#pure-compatibility) and [Powerlevel9k](#powerlevel9k-compatibility) emulation is built-in.
To emulate the appearence of other themes, you'll need to write a suitable configuration file. The
best way to go about it is to run `p10k configure`, select the style that is the closest to your
goal and then edit `~/.p10k.zsh`.

The full range of Powerlevel10k appearance spans from spartan:

![Powerlevel10k Spartan Style](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/spartan-style.png)

To ~~ridiculous~~ extravagant:

![Powerlevel10k Extravagant Style](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/extravagant-style.png)

### Batteries included

Powerlevel10k comes with dozens of built-in high quality segments. When you run `p10k configure`
and choose any style except Pure, most of these segments get enabled by default. Some must be
manually enabled by opening `~/.p10k.zsh` and uncommenting them. You can enable as many segments as
you like. It won't slow down your prompt or Zsh startup.

| Segment | Meaning |
|--------:|---------|
| `os_icon` | your OS logo (apple for macOS, swirl for debian, etc.) |
| `dir` | current working directory |
| `vcs` | Git repository status |
| `prompt_char` | multi-functional prompt symbol; changes depending on vi mode: `❯`, `❮`, `Ⅴ`, `▶` for insert, command, visual and replace mode respectively; turns red on error |
| `context` | user@hostname |
| `status` | exit code of the last command |
| `command_execution_time` | duration (wall time) of the last command |
| `background_jobs` | presence of background jobs |
| `time` | current time |
| `direnv` | [direnv](https://direnv.net/) status |
| `virtualenv` | python environment from [venv](https://docs.python.org/3/library/venv.html) |
| `anaconda` | virtual environment from [conda](https://conda.io/) |
| `pyenv` | python environment from [pyenv](https://github.com/pyenv/pyenv) |
| `goenv` | go environment from [goenv](https://github.com/syndbg/goenv) |
| `nodenv` | node.js environment from [nodenv](https://github.com/nodenv/nodenv) |
| `nvm` | node.js environment from [nvm](https://github.com/nvm-sh/nvm) |
| `nodeenv` | node.js environment from [nodeenv](https://github.com/ekalinin/nodeenv) |
| `rbenv` | ruby environment from [rbenv](https://github.com/rbenv/rbenv) |
| `rvm` | ruby environment from [rvm](https://rvm.io) |
| `fvm` | flutter environment from [fvm](https://github.com/leoafarias/fvm) |
| `luaenv` | lua environment from [luaenv](https://github.com/cehoffman/luaenv) |
| `jenv` | java environment from [jenv](https://github.com/jenv/jenv) |
| `plenv` | perl environment from [plenv](https://github.com/tokuhirom/plenv) |
| `node_version` | [node.js](https://nodejs.org/) version |
| `go_version` | [go](https://golang.org) version |
| `rust_version` | [rustc](https://www.rust-lang.org) version |
| `dotnet_version` | [dotnet](https://dotnet.microsoft.com) version |
| `kubecontext` | current [kubernetes](https://kubernetes.io/) context |
| `terraform` | [terraform](https://www.terraform.io) workspace |
| `aws` | [aws profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) |
| `aws_eb_env` | [aws elastic beanstalk](https://aws.amazon.com/elasticbeanstalk/) environment |
| `azure` | [azure](https://docs.microsoft.com/en-us/cli/azure) account name |
| `gcloud` | [google cloud](https://cloud.google.com/) cli acccount and project |
| `google_app_cred` | [google application credentials](https://cloud.google.com/docs/authentication/production) |
| `nordvpn` | [nordvpn](https://nordvpn.com/) connection status |
| `ranger` | [ranger](https://github.com/ranger/ranger) shell |
| `nnn` | [nnn](https://github.com/jarun/nnn) shell |
| `vim_shell` | [vim](https://www.vim.org/) shell (`:sh`) |
| `midnight_commander` | [midnight commander](https://midnight-commander.org/) shell |
| `todo` | [todo](https://github.com/todotxt/todo.txt-cli) items |
| `timewarrior` | [timewarrior](https://timewarrior.net/) tracking status |
| `vpn_ip` | virtual private network indicator |
| `load` | CPU load |
| `disk_usage` | disk usage |
| `ram` | free RAM |
| `swap` | used swap |
| `public_ip` | public ip address |
| `proxy` | system-wide http/https/ftp proxy |
| `battery` | internal battery state and charge level (yep, batteries *literally* included) |

## Installation

### Manual

```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc
```

This is the simplest kind of installation and it works even if you are using a plugin manager. Just
make sure to disable your current theme in your plugin manager. See
[troubleshooting](#cannot-make-powerlevel10k-work-with-my-plugin-manager) for help.

### Oh My Zsh

```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
```

Set `ZSH_THEME=powerlevel10k/powerlevel10k` in your `~/.zshrc`.

### Prezto

Add `zstyle :prezto:module:prompt theme powerlevel10k` to your `~/.zpreztorc`.

### Zim

Add `zmodule romkatv/powerlevel10k` to your `.zimrc` and run `zimfw install`.

### Antigen

Add `antigen theme romkatv/powerlevel10k` to your `~/.zshrc`. Make sure you have `antigen apply`
somewhere after it.

### Zplug

Add `zplug romkatv/powerlevel10k, as:theme, depth:1` to your `~/.zshrc`.

### Zgen

Add `zgen load romkatv/powerlevel10k powerlevel10k` to your `~/.zshrc`.

### Antibody

Add `antibody bundle romkatv/powerlevel10k` to your `~/.zshrc`.

### Zplugin

Add `zplugin ice depth=1; zplugin light romkatv/powerlevel10k` to your `~/.zshrc`.

The use of `depth=1` ice is optional. Other types of ice are neither recommended nor officially
supported by Powerlevel10k.

## Configuration

### For new users

On the first run, Powerlevel10k configuration wizard will ask you a few questions and configure
your prompt. If it doesn't trigger automatically, type `p10k configure`. You can further customize
your prompt by editing `~/.p10k.zsh`.

### For Powerlevel9k users

If you've been using Powerlevel9k before, **do not remove the configuration options**. Powerlevel10k
will pick them up and provide you with the same prompt UI you are used to. Powerlevel10k recognized
all configuration options used by Powerlevel9k. See Powerlevel9k
[configuration guide](https://github.com/Powerlevel9k/powerlevel9k/blob/master/README.md#prompt-customization).

To go beyond the functionality of Powerlevel9k, type `p10k configure` and explore the unique styles
and features Powerlevel10k has to offer. You can further customize your prompt by editing
`~/.p10k.zsh`.

## Fonts

Powerlevel10k doesn't require custom fonts but can take advantage of them if they are available.
It works well with [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts),
[Source Code Pro](https://github.com/adobe-fonts/source-code-pro),
[Font Awesome](https://fontawesome.com/), [Powerline](https://github.com/powerline/fonts), and even
the default system fonts. The full choice of style options is available only when using
[Nerd Fonts](https://github.com/ryanoasis/nerd-fonts).

👇 **Recommended font**: Meslo Nerd Font patched for Powerlevel10k. 👇

### <a name='recommended-meslo-nerd-font-patched-for-powerlevel10k'></a>Meslo Nerd Font patched for Powerlevel10k

Gorgeous monospace font designed by Jim Lyles for Apple, customized by André Berg, patched by Ryan
L McIntyre of Nerd Fonts, and hand-edited in FontForge by yours trully. Contains all glyphs and
symbols that Powerlevel10k may need. Battle-tested in dozens of different terminals on all major
operating systems.

#### Automatic font installation

If you are using iTerm2 or Termux, `p10k configure` can install the recommended font for you.
Simply answer `Yes` when asked whether to install *Meslo Nerd Font*.

If you are using a different terminal, proceed with manual font installation.

#### Manual font installation

Download these four ttf files:
- [MesloLGS NF Regular.ttf](https://github.com/romkatv/dotfiles-public/raw/master/.local/share/fonts/NerdFonts/MesloLGS%20NF%20Regular.ttf)
- [MesloLGS NF Bold.ttf](https://github.com/romkatv/dotfiles-public/raw/master/.local/share/fonts/NerdFonts/MesloLGS%20NF%20Bold.ttf)
- [MesloLGS NF Italic.ttf](https://github.com/romkatv/dotfiles-public/raw/master/.local/share/fonts/NerdFonts/MesloLGS%20NF%20Italic.ttf)
- [MesloLGS NF Bold Italic.ttf](https://github.com/romkatv/dotfiles-public/raw/master/.local/share/fonts/NerdFonts/MesloLGS%20NF%20Bold%20Italic.ttf)

Double-click on each file and press "Install". This will make `MesloLGS NF` font available to all
applications on your system. Configure your terminal to use this font:

- **iTerm2**: Open *iTerm2 → Preferences → Profiles → Text* and set *Font* to `MesloLGS NF`.
- **Apple Terminal** Open *Terminal → Preferences → Profiles → Text*, click *Change* under *Font*
  and select `MesloLGS NF` family.
- **Hyper**: Open *Hyper → Edit → Preferences* and change the value of `fontFamily` under
  `module.exports.config` to `MesloLGS NF`.
- **Visual Studio Code**: Open *File → Preferences → Settings*, enter
  `terminal.integrated.fontFamily` in the search box and set the value to `MesloLGS NF`.
- **GNOME Terminal** (the default Ubuntu terminal): Open *Terminal → Preferences* and click on the
  selected profile under *Profiles*. Check *Custom font* under *Text Appearance* and select
  `MesloLGS NF Regular`.
- **Konsole**: Open *Settings → Edit Current Profile → Appearance*, click *Select Font* and select
  `MesloLGS NF Regular`.
- **Tilix**: Open *Tilix → Preferences* and click on the selected profile under *Profiles*. Check
  *Custom font* under *Text Appearance* and select `MesloLGS NF Regular`.
- **Windows Console Host** (the old thing): Click the icon in the top left corner, then
  *Properties → Font* and set *Font* to `MesloLGS NF`.
- **Windows Terminal** (the new thing): Open *Settings* (`Ctrl+,`), search for `fontFace` and set
  value to `MesloLGS NF` for every profile.
- **Termux**: Type `p10k configure` and answer `Yes` when asked whether to install
  *Meslo Nerd Font*.

Run `p10k configure` to pick the best style for your new font.

_Using a different terminal and know how to set the font for it? Share your knowledge by sending a PR
to expand the list!_

## Try it in Docker

Try Powerlevel10k in Docker. You can safely make any changes to the file system while trying out
the theme. Once you exit zsh, the image is deleted.

```zsh
docker run -e TERM -e COLORTERM -it --rm debian:buster bash -uec '
  apt update
  apt install -y git zsh nano vim
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo "source ~/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc
  cd ~/powerlevel10k
  exec zsh'
```

Tip: Install [the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k) before
running the Docker command to get access to all prompt styles.

Tip: Run `p10k configure` while in Docker to try a different prompt style.

## License

Powerlevel10k is released under the
[MIT license](https://github.com/romkatv/powerlevel10k/blob/master/LICENSE).

## FAQ

### I'm using Powerlevel9k with Oh My Zsh. How do I migrate?

1. Run this command:
```zsh
# Add powerlevel10k to the list of Oh My Zsh themes.
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
# Replace ZSH_THEME="powerlevel9k/powerlevel9k" with ZSH_THEME="powerlevel10k/powerlevel10k".
sed 's/powerlevel9k/powerlevel10k/g' -i ~/.zshrc
# Restart Zsh.
exec zsh
```
2. *Optional but highly recommended:*
   1. Install [the recommended font](#meslo-nerd-font-patched-for-powerlevel10k).
   1. Type `p10k configure` and chose your favorite prompt style.

Related: [Powerlevel9k compatibility](#powerlevel9k-compatibility).

### Is it really fast?

Yes.

[![asciicast](https://asciinema.org/a/NHRjK3BMePw66jtRVY2livHwZ.svg)](https://asciinema.org/a/NHRjK3BMePw66jtRVY2livHwZ)

Benchmark results obtained with
[zsh-prompt-benchmark](https://github.com/romkatv/zsh-prompt-benchmark) on an Intel i9-7900X
running Ubuntu 18.04 with the config from the demo.

| Theme               | Prompt Latency |
|---------------------|---------------:|
| powerlevel9k/master |        1046 ms |
| powerlevel9k/next   |        1005 ms |
| **powerlevel10k**   |     **8.7 ms** |

Powerlevel10k is over 100 times faster than Powerlevel9k in this benchmark.

In fairness, Powerlevel9k has acceptable latency when given a spartan configuration. If all you need
is the current directory without truncation or shortening, Powerlevel9k can render it for you in
17 ms. Powerlevel10k can do the same 30 times faster but it won't matter in practice because 17 ms
is fast enough (the threshold where latency becomes noticeable is around 50 ms). You have to be
careful with Powerlevel9k configuration as it's all too easy to make prompt frustratingly slow.
Powerlevel10k, on the other hand, doesn't require trading latency for utility -- it's virtually
instant with any configuration. It stays well below the 50 ms mark, leaving most of the latency
budget for other plugins you might install.

### How do I enable instant prompt?

See [instant prompt](#instant-prompt) to learn what instant prompt is. This section explains how
you can enable it and lists caveats that you should be aware of.

Instant prompt can be enabled either through `p10k configure` or by manually adding the following
code snippet at the top of `~/.zshrc`:

```zsh
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
```

It's important that you copy the lines verbatim. Don't replace `source` with something else, don't
call `zcompile`, don't redirect output, etc.

When instant prompt is enabled, for the duration of zsh initialization standard input is redirected
to `/dev/null` and standard output with standard error are redirected to a temporary file. Once zsh
is fully initialized, standard file descriptors are restored and the content of the temporary file
is printed out.

When using instant prompt, you should carefully check any output that appears on zsh startup as it
may indicate that initialization has been altered, or perhaps even broken, by instant prompt.
Initialization code that may require console input, such as asking for a keyring password or for a
*[y/n]* confirmation, must be moved above the instant prompt preamble in `~/.zshrc`. Initialization
code that merely prints to console but never reads from it will work correctly with instant prompt,
although output that normally has colors may appear uncolored. You can either leave it be, suppress
the output, or move it above the instant prompt preamble.

Here's an example of `~/.zshrc` that breaks when instant prompt is enabled:

```zsh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

keychain id_rsa --agents ssh  # asks for password
chatty-script                 # spams to stdout even when everything is fine
# ...
```

Fixed version:

```zsh
keychain id_rsa --agents ssh  # moved before instant prompt

# OK to perform console I/O before this point.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# From this point on, until zsh is fully initialized, console input won't work and
# console output may appear uncolored.

chatty-script >/dev/null      # spam output suppressed
# ...
```

If `POWERLEVEL9K_INSTANT_PROMPT` is unset or set to `verbose`, Powerlevel10k will print a warning
when it detects console output during initialization to bring attention to potential issues. You can
silence this warning (without suppressing console output) with `POWERLEVEL9K_INSTANT_PROMPT=quiet`.
This is recommended if some initialization code in `~/.zshrc` prints to console and it's infeasible
to move it above the instant prompt preamble or to suppress its output. You can completely disable
instant prompt with `POWERLEVEL9K_INSTANT_PROMPT=off`. Do this if instant prompt breaks zsh
initialization and you don't know how to fix it.

*NOTE: Instant prompt requires zsh >= 5.4. It's OK to enable it even when using an older version of
zsh but it won't do anything.*

### Why do I have a question mark symbol in my prompt? Is my font broken?

If it looks like a regular `?`, that's normal. It means you have untracked files in the current Git
repository. Type `git status` to see these files. You can change this symbol or disable the display
of untracked files altogether. Search for `untracked files` in `~/.p10k.zsh`.

You can also get a weird-looking question mark in your prompt if your terminal's font is missing
some glyphs. To fix this problem,
[install the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k) and run
`p10k configure`.

### What do different symbols in Git status mean?

When using *Lean*, *Classic* or *Rainbow* style, Git status may look like this:

```text
feature:master ⇣42⇡42 *42 merge ~42 +42 !42 ?42
```

| Symbol    | Meaning                                                              | Source                                                 |
| --------- | -------------------------------------------------------------------- | ------------------------------------------------------ |
| `feature` | current branch; replaced with `#tag` or `@commit` if not on a branch | `git status`                                           |
| `master`  | remote tracking branch; only shown if different from local branch    | `git rev-parse --abbrev-ref --symbolic-full-name @{u}` |
| `⇣42`     | this many commits behind the remote                                  | `git status`                                           |
| `⇡42`     | this many commits ahead of the remote                                | `git status`                                           |
| `*42`     | this many stashes                                                    | `git stash list`                                       |
| `merge`   | repository state                                                     | `git status`                                           |
| `~42`     | this many merge conflicts                                            | `git status`                                           |
| `+42`     | this many staged changes                                             | `git status`                                           |
| `!42`     | this many unstaged changes                                           | `git status`                                           |
| `?42`     | this many untracked files                                            | `git status`                                           |

See also: [How do I change the format of Git status?](#how-do-i-change-the-format-of-git-status)

### How do I change the format of Git status?

To change the format of Git status, open `~/.p10k.zsh`, search for `my_git_formatter` and edit its
source code.

### How do I add username and/or hostname to prompt?

When using *Lean*, *Classic* or *Rainbow* style, prompt shows `username@hostname` when you are
logged in as root or via SSH. There is little value in showing `username` or `hostname` when you are
logged in to your local machine as a normal user. So the absence of `username@hostname` in your
prompt is an indication that you are working locally and that you aren't root. You can change it,
however.

Open `~/.p10k.zsh`. Close to the top you can see the most important parameters that define which
segments are shown in your prompt. All generally useful prompt segments are listed in there. Some of
them are enabled, others are commented out. One of them is of interest to you.

```zsh
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  ...
  context                 # user@hostname
  ...
)
```

Search for `context` to find the section in the config that lists parameters specific to this prompt
segment. You should see the following lines:

```zsh
# Don't show context unless running with privileges or in SSH.
# Tip: Remove the next line to always show context.
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
```

If you follow the tip and remove (or comment out) the last line, you'll always see
`username@hostname` in prompt. You can change the format to just `username`, or change the color, by
adjusting the values of parameters nearby. There are plenty of comments to help you navigate.

Finally, you can move `context` segment to where you want it to be in your prompt. Perhaps somewhere
within `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS`.

### Why some prompt segments appear and disappear as I'm typing?

Prompt segments can be configured to be shown only when the current command you are typing invokes
a releavant tool.

```zsh
# Show prompt segment "kubecontext" only when the command you are typing
# invokes kubectl, helm, kubens, kubectx or oc.
typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc'
```

Configs created by `p10k configure` may contain parameters of this kind. To customize when different
prompt segments are shown, open `~/.p10k.zsh`, search for `SHOW_ON_COMMAND` and either remove these
parameters or change their values.

### How do I change colors?

You can either change the color palette used by your terminal or set colors through Powerlevel10k
configuration parameters.

#### Change the color palette used by your terminal

How exactly you change the terminal color pallete (a.k.a. color scheme, or theme) depends on the
kind of terminal you are using. Look around in terminal's settings/preferences or consult
documentation.

When you change the color palette used by your terminal, it usually affects only the first 16
colors, numbered from 0 to 15. In order to see any effect on Powerlevel10k prompt, you need to
use prompt style that utilizes these low-numbered colors. Type `p10k configure` and select
*Rainbow*, *Lean with 8 colors* or *Pure with original colors*. Other styles use higher-numbered
colors, so they look the same in any terminal color palette.

#### Set colors through Powerlevel10k configuration parameters

Open `~/.p10k.zsh`, search for "color", "foreground" and "background" and change values of
appropriate parameters. For example, here's how you can set the foreground of `time` prompt segment
to bright red:

```zsh
typeset -g POWERLEVEL9K_TIME_FOREGROUND=160
```

Colors are specified using numbers from 0 to 255. Colors from 0 to 15 look differently in different
terminals. Many terminals also support customization of these colors through color palettes
(a.k.a. color schemes, or themes). Colors from 16 to 255 always look the same.

To see how different colors look in your terminal, run the following command:

```zsh
for i in {0..255}; do print -Pn "%K{$i} %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%8)):#7}:+$'\n'}; done
```

### Why does Powerlevel10k spawn extra processes?

Powerlevel10k uses [gitstatus](https://github.com/romkatv/gitstatus) as the backend behind `vcs`
prompt; gitstatus spawns `gitstatusd` and `zsh`. See
[gitstatus](https://github.com/romkatv/gitstatus) for details. Powerlevel10k may also spawn `zsh`
to perform computation without blocking prompt. To avoid security hazard, these background processes
aren't shared by different interactive shells.

### Are there configuration options that make Powerlevel10k slow?

No, Powerlevel10k is always fast, with any configuration you throw at it. If you have noticeable
prompt latency when using Powerlevel10k, please
[open an issue](https://github.com/romkatv/powerlevel10k/issues).

### Is Powerlevel10k fast to load?

Yes, provided that you are using zsh >= 5.4.

Loading time, or time to first prompt, can be measured with the following benchmark:

```zsh
time (repeat 1000 zsh -dfis <<< 'source ~/powerlevel10k/powerlevel10k.zsh-theme')
```

*NOTE: This measures time to first complete prompt. Powerlevel10k can also display a
[limited prompt](#what-is-instant-prompt) before the full-featured prompt is ready.*

Running this command with `~/powerlevel10k` as the current directory on the same machine as in the
[prompt benchmark](#is-it-really-fast) takes 29 seconds (29 ms per invocation). This is about 6
times faster than powerlevel9k/master and 17 times faster than powerlevel9k/next.

### Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?

Almost. There are a few differences.

- By default only `git` vcs backend is enabled in Powerlevel10k. If you need `svn` and `hg`, add
  them to `POWERLEVEL9K_VCS_BACKENDS`.
- Powerlevel10k strives to be bug-compatible with Powerlevel9k but not when it comes to egregious
  bugs. If you accidentally rely on these bugs, your prompt will differ between Powerlevel9k and
  Powerlevel10k. Some examples:
  - Powerlevel9k ignores some options that are set after the theme is sourced while Powerlevel10k
    respects all options. If you see different icons in Powerlevel9k and Powerlevel10k, you've
    probably defined `POWERLEVEL9K_MODE` before sourcing the theme. This parameter gets ignored
    by Powerlevel9k but honored by Powerlevel10k. If you want your prompt to look in Powerlevel10k
    the same as in Powerlevel9k, remove `POWERLEVEL9K_MODE`.
  - Powerlevel9k doesn't respect `ZLE_RPROMPT_INDENT`. As a result, right prompt in Powerlevel10k
    can have an extra space at the end compared to Powerlevel9k. Set `ZLE_RPROMPT_INDENT=0` if you
    don't want that space. More details in
    [troubleshooting](#extra-space-without-background-on-the-right-side-of-right-prompt).
  - Powerlevel9k has inconsistent spacing around icons. This was fixed in Powerlevel10k. Set
    `POWERLEVEL9K_LEGACY_ICON_SPACING=true` to get the same spacing as in Powerlevel9k.  More
    details in [troubleshooting](#extra-spaces-after-some-icons).
  - There are
    [dozens more bugs](https://github.com/Powerlevel9k/powerlevel9k/issues/created_by/romkatv) in
    Powerlevel9k that don't exist in Powerlevel10k.

If you notice any other changes in prompt appearance when switching from Powerlevel9k to
Powerlevel10k, please [open an issue](https://github.com/romkatv/powerlevel10k/issues).

### Is there an AUR package for Powerlevel10k?

Yes, [zsh-theme-powerlevel10k-git](https://aur.archlinux.org/packages/zsh-theme-powerlevel10k-git/).
This package is owned by an unaffiliated volunteer.

### What is the minimum supported zsh version?

Zsh 5.1 or newer should work. Fast startup requires zsh >= 5.4.

### How were these screenshots and animated gifs created?

All screenshots and animated gifs were recorded in GNOME Terminal with
[the recommended font](#meslo-nerd-font-patched-for-powerlevel10k) and Tango Dark color scheme with
custom background color (`#171A1B` instead of `#2E3436` -- twice as dark).

![GNOME Terminal Color Settings](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/gnome-terminal-colors.png)

## Troubleshooting

### Icons, glyphs or powerline symbols don't render.

Restart your terminal, [install the recommended font](
  #recommended-meslo-nerd-font-patched-for-powerlevel10k) and run `p10k configure`.

###  zsh: character not in range

Type `echo '\u276F'`. If you get an error saying "zsh: character not in range", your locale
doesn't support UTF-8. You need to fix it. If you are running zsh over SSH, see
[this](https://github.com/romkatv/powerlevel10k/issues/153#issuecomment-518347833). If you are
running zsh locally, Google "set UTF-8 locale in *your OS*".

### Cursor is in the wrong place

Type `echo '\u276F'`. If you get an error saying "zsh: character not in range", see the
[previous section](#zsh-character-not-in-range).

If the `echo` command prints `❯` but the cursor is still in the wrong place, install
[the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k) and run
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

#### If the prompt line aligns with the frame

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

#### If the prompt line is longer than the frame

```text
+-----------------------------+
| romka@adam ✓ ~/powerlevel10k |
+-----------------------------+
```

This is usually caused by a terminal bug or misconfiguration that makes it print ambiguous-width
characters as double-width instead of single width. For example,
[this issue](https://github.com/romkatv/powerlevel10k/issues/165).

#### If the prompt line is shorter than the frame and is mangled

```text
+------------------------------+
| romka@adam ✓~/powerlevel10k |
+------------------------------+
```

Note that this prompt is different from the original as it's missing a space after the checkmark.

This can be caused by a low-level bug in macOS. See
[this issue](https://github.com/romkatv/powerlevel10k/issues/241).

#### If the prompt line is shorter than the frame and is not mangled

```text
+--------------------------------+
| romka@adam ✓ ~/powerlevel10k |
+--------------------------------+
```

This can be caused by misconfigured locale. See
[this issue](https://github.com/romkatv/powerlevel10k/issues/251).

### Prompt wrapping around in a weird way

See [cursor is in the wrong place](#cursor-is-in-the-wrong-place).

### Right prompt is in the wrong place

See [cursor is in the wrong place](#cursor-is-in-the-wrong-place).

### Configuration wizard run automatically every time zsh is started

When Powerlevel10k starts, it automatically runs `p10k configure` if no `POWERLEVEL9K_*`
parameters are defined. Based on your prompt style choices, the configuration wizard creates
`~/.p10k.zsh` with a bunch of `POWERLEVEL9K_*` parameters in it and adds a line to `~/.zshrc` to
source this file. The next time you start zsh, the configuration wizard shouldn't run automatically.
If it does, this means the evaluation of `~/.zshrc` terminates prematurely before it reaches the
line that sources `~/.p10k.zsh`. This most often happens due to syntax errors in `~/.zshrc`. These
errors get hidden by the configuration wizard screen, so you don't notice them. Scroll up in the
first configuration wizard screen to see these errors. Alternatively, run
`POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true zsh` to start zsh without automatically running the
configuration wizard. Once you can see the errors, fix `~/.zshrc` to get rid of them.

### Cannot install the recommended font

Once you download [the recommended font](#recommended-meslo-nerd-font-patched-for-powerlevel10k),
you can install it just like any other font. Google "how to install fonts on *your OS*".

### Extra spaces in prompt compared to Powerlevel9k

When using Powerlevel10k with a Powerlevel9k config, you might get additional spaces in prompt here
and there. These come in two flavors.

#### Extra space without background on the right side of right prompt

tl;dr: Add `ZLE_RPROMPT_INDENT=0` to `~/.zshrc` to get rid of that space.

From [Zsh documentation](
  http://zsh.sourceforge.net/Doc/Release/Parameters.html#index-ZLE_005fRPROMPT_005fINDENT):

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

![ZLE_RPROMPT_INDENT: Powerlevel10k vs Powerlevel9k](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/p9k-vs-p10k-zle-rprompt-indent.png)

Powerlevel9k issue: [powerlevel9k#1292](https://github.com/Powerlevel9k/powerlevel9k/issues/1292).
It's been fixed in the development branch of Powerlevel9k but the fix hasn't yet made it to
`master`.

Add `ZLE_RPROMPT_INDENT=0` to `~/.zshrc` to get the same spacing on the right edge of prompt as in
Powerlevel9k.

#### Extra spaces after some icons

tl;dr: Add `POWERLEVEL9K_LEGACY_ICON_SPACING=true` to `~/.zshrc` to get rid of these spaces.

Spacing around icons in Powerlevel9k is inconsistent.

![ZLE_RPROMPT_INDENT: Powerlevel10k vs Powerlevel9k](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/p9k-vs-p10k-icon-spacing.png)

This inconsistency is a constant source of annoyance, so it was fixed in Powerlevel10k.
Unfortunately, this means that users upgrading from Powerlevel9k will notice differences in spacing
around some icons.

Add `POWERLEVEL9K_LEGACY_ICON_SPACING=true` to `~/.zshrc` to get the same spacing around icons as in
Powerlevel9k.

### Cannot make Powerlevel10k work with my plugin manager

If the [installation instructions](#installation) didn't work for you, try disabling your current
theme (so that you end up with no theme) and then installing Powerlevel10k manually.

1. Disable the current theme in your framework / plugin manager.

- **oh-my-zsh:** Open `~/.zshrc` and remove the line that sets `ZSH_THEME`. It might look like this:
  `ZSH_THEME="powerlevel9k/powerlevel9k"`.
- **zplug:** Open `~/.zshrc` and remove the `zplug` command that refers to your current theme. For
  example, if you are currently using Powerlevel9k, look for
  `zplug bhilburn/powerlevel9k, use:powerlevel9k.zsh-theme`.
- **prezto:** Open `~/.zpreztorc` and put `zstyle :prezto:module:prompt theme off` in it. Remove
  any other command that sets `theme` such as `zstyle :prezto:module:prompt theme powerlevel9k`.
- **antigen:** Open `~/.zshrc` and remove the line that sets `antigen theme`. It might look like
  this: `antigen theme powerlevel9k/powerlevel9k`.

2. Install Powerlevel10k manually.

```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc
```

This method of installation won't make anything slower or otherwise sub-par.

## Table of contents

1. [Features](#features)
   1. [Configuration wizard](#configuration-wizard)
   1. [Uncompromising performance](#uncompromising-performance)
   1. [Powerlevel9k compatibility](#powerlevel9k-compatibility)
   1. [Pure compatibility](#pure-compatibility)
   1. [Instant prompt](#instant-prompt)
   1. [Show On Command](#show-on-command)
   1. [Transient prompt](#transient-prompt)
   1. [Current directory that just works](#current-directory-that-just-works)
   1. [Extremely customizable](#extremely-customizable)
   1. [Batteries included](#batteries-included)
1. [Installation](#installation)
   1. [Manual](#manual)
   1. [Oh My Zsh](#oh-my-zsh)
   1. [Prezto](#prezto)
   1. [Zim](#zim)
   1. [Antigen](#antigen)
   1. [Zplug](#zplug)
   1. [Zgen](#zgen)
   1. [Antibody](#antibody)
   1. [Zplugin](#zplugin)
1. [Configuration](#configuration)
   1. [For new users](#for-new-users)
   1. [For Powerlevel9k users](#for-powerlevel9k-users)
1. [Fonts](#fonts)
   1. [Meslo Nerd Font patched for Powerlevel10k](#meslo-nerd-font-patched-for-powerlevel10k)
      1. [Automatic font installation](#automatic-font-installation)
      1. [Manual font installation](#manual-font-installation)
1. [Try it in Docker](#try-it-in-docker)
1. [License](#license)
1. [FAQ](#faq)
   1. [I'm using Powerlevel9k with Oh My Zsh. How do I migrate?](#im-using-powerlevel9k-with-oh-my-zsh-how-do-i-migrate)
   1. [Is it really fast?](#is-it-really-fast)
   1. [What is instant prompt?](#what-is-instant-prompt)
   1. [Why do my icons and/or powerline symbols look bad?](#why-do-my-icons-andor-powerline-symbols-look-bad)
   1. [I'm getting "character not in range" error. What gives?](#im-getting-character-not-in-range-error-what-gives)
   1. [Why is my cursor in the wrong place?](#why-is-my-cursor-in-the-wrong-place)
   1. [Why is my prompt wrapping around in a weird way?](#why-is-my-prompt-wrapping-around-in-a-weird-way)
   1. [Why is my right prompt in the wrong place?](#why-is-my-right-prompt-in-the-wrong-place)
   1. [Why does the configuration wizard run automatically every time I start zsh?](#why-does-the-configuration-wizard-run-automatically-every-time-i-start-zsh)
   1. [I cannot install the recommended font. Help!](#i-cannot-install-the-recommended-font-help)
   1. [Why do I have a question mark symbol in my prompt? Is my font broken?](#why-do-i-have-a-question-mark-symbol-in-my-prompt-is-my-font-broken)
   1. [What do different symbols in Git status mean?](#what-do-different-symbols-in-git-status-mean)
   1. [How do I change the format of Git status?](#how-do-i-change-the-format-of-git-status)
   1. [How do I add username and/or hostname to prompt?](#how-do-i-add-username-andor-hostname-to-prompt)
   1. [How do I change colors?](#how-do-i-change-colors)
   1. [Why some prompt segments appear and disappear as I'm typing?](#why-some-prompt-segments-appear-and-disappear-as-im-typing)
   1. [Why does Powerlevel10k spawn extra processes?](#why-does-powerlevel10k-spawn-extra-processes)
   1. [Are there configuration options that make Powerlevel10k slow?](#are-there-configuration-options-that-make-powerlevel10k-slow)
   1. [Is Powerlevel10k fast to load?](#is-powerlevel10k-fast-to-load)
   1. [Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?](#does-powerlevel10k-always-render-exactly-the-same-prompt-as-powerlevel9k-given-the-same-config)
   1. [Why do I get extra spaces in prompt when I use my Powerlevel9k config with Powerlevel10k?](#why-do-i-get-extra-spaces-in-prompt-when-i-use-my-powerlevel9k-config-with-powerlevel10k)
   1. [Is there an AUR package for Powerlevel10k?](#is-there-an-aur-package-for-powerlevel10k)
   1. [I cannot make Powerlevel10k work with my plugin manager. Help!](#i-cannot-make-powerlevel10k-work-with-my-plugin-manager-help)
   1. [What is the minimum supported zsh version?](#what-is-the-minimum-supported-zsh-version)
   1. [How were these screenshots and animated gifs created?](#how-were-these-screenshots-and-animated-gifs-created)
