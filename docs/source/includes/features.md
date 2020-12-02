# Features

## Configuration Wizard

```zsh
p10k configure
```

![Powerlevel10k Configuration Wizard](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/configuration-wizard.gif)

Type `p10k configure` to access the builtin configuration wizard right from your terminal.

All styles except [Pure](#pure-compatibility) are functionally equivalent. They display the same
information and differ only in presentation.

Configuration wizard creates `~/.p10k.zsh` based on your preferences. Additional prompt
customization can be done by editing this file. It has plenty of comments to help you navigate
through configuration options.

_Tip_: Install [the recommended font](../#recommended-font-meslo-nerd-font-patched-for-powerlevel10k) before
running `p10k configure` to unlock all prompt styles.

_FAQ:_

- [What is the best prompt style in the configuration wizard?](#what-is-the-best-prompt-style-in-the-configuration-wizard)
- [What do different symbols in Git status mean?](#what-do-different-symbols-in-git-status-mean)
- [How do I change prompt colors?](#how-do-i-change-prompt-colors)

_Troubleshooting_:

- [Some prompt styles are missing from the configuration wizard](#some-prompt-styles-are-missing-from-the-configuration-wizard).
- [Question mark in prompt](#question-mark-in-prompt).
- [Icons, glyphs or powerline symbols don't render](#icons-glyphs-or-powerline-symbols-don-39-t-render).
- [Sub-pixel imperfections around powerline symbols](#sub-pixel-imperfections-around-powerline-symbols).
- [Directory is difficult to see in prompt when using Rainbow style](#directory-is-difficult-to-see-in-prompt-when-using-rainbow-style).

## Uncomprising Performance

When you hit _ENTER_, the next prompt appears instantly. With Powerlevel10k there is no prompt lag.
If you install Cygwin on Raspberry Pi, `cd` into a Linux Git repository and activate enough prompt
segments to fill four prompt lines on both sides of the screen... wait, that's just crazy and no
one ever does that. Probably impossible, too. The point is, Powerlevel10k prompt is always fast, no
matter what you do!

![Powerlevel10k Performance](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/performance.gif)

Note how the effect of every command is instantly reflected by the very next prompt.

```zsh
timew start hack linux
```

```zsh
touch x y
```

```zsh
rm COPYING
```

```zsh
echo 3.7.3 >.python-version
```

| Command                       | Prompt Indicator |                                                               Meaning |
| ----------------------------- | :--------------: | --------------------------------------------------------------------: |
| `timew start hack linux`      |  `🛡️ hack linux`  |      time tracking enabled in [timewarrior](https://timewarrior.net/) |
| `touch x y`                   |       `?2`       |                                     2 untracked files in the Git repo |
| `rm COPYING`                  |       `!1`       |                                     1 unstaged change in the Git repo |
| `echo 3.7.3 >.python-version` |    `🐍 3.7.3`     | the current python version in [pyenv](https://github.com/pyenv/pyenv) |

Other Zsh themes capable of displaying the same information either produce prompt lag or print
prompt that doesn't reflect the current state of the system and then refresh it later. With
Powerlevel10k you get fast prompt _and_ up-to-date information.

_FAQ_: [Is it really fast?](#is-it-really-fast)

## Powerlevel9k compatibility

Powerlevel10k understands all [Powerlevel9k](https://github.com/Powerlevel9k/powerlevel9k)
configuration parameters.

![Powerlevel10k Compatibility with 9k](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/9k-compatibility.gif)

[Migration](#installation) from Powerlevel9k to Powerlevel10k is a straightforward process. All
your `POWERLEVEL9K` configuration parameters will still work. Prompt will look the same as before
([almost](#does-powerlevel10k-always-render-exactly-the-same-prompt-as-powerlevel9k-given-the-same-config))
but it will be [much faster](#uncomprising-performance) ([certainly](#is-it-really-fast)).

_FAQ_:

- [I'm using Powerlevel9k with Oh My Zsh. How do I migrate?](#i-39-m-using-powerlevel9k-with-oh-my-zsh-how-do-i-migrate)
- [Does Powerlevel10k always render exactly the same prompt as Powerlevel9k given the same config?](#does-powerlevel10k-always-render-exactly-the-same-prompt-as-powerlevel9k-given-the-same-config)
- [What is the relationship between Powerlevel9k and Powerlevel10k?](#What-is-the-relationship-between-powerlevel9k-and-powerlevel10k)

## Pure compatibility

Powerlevel10k can produce the same prompt as [Pure](https://github.com/sindresorhus/pure). Type
`p10k configure` and select _Pure_ style.

![Powerlevel10k Pure Style](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/pure-style.gif)

You can still use Powerlevel10k features such as [transient prompt](#transient-prompt) or
[instant prompt](#instant-prompt) when sporting Pure style.

To customize prompt, edit `~/.p10k.zsh`. Powerlevel10k doesn't recognize Pure configuration
parameters, so you'll need to use `POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3` instead of
`PURE_CMD_MAX_EXEC_TIME=3`, etc. All relevant parameters are in `~/.p10k.zsh`. This file has
plenty of comments to help you navigate through it.

_FAQ:_ [What is the best prompt style in the configuration wizard?](#what-is-the-best-prompt-style-in-the-configuration-wizard)

## Instant prompt

If your `~/.zshrc` loads many plugins, or perhaps just a few slow ones
(for example, [pyenv](https://github.com/pyenv/pyenv) or [nvm](https://github.com/nvm-sh/nvm)), you
may have noticed that it takes some time for Zsh to start.

![Powerlevel10k No Instant Prompt](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/no-instant-prompt.gif)

Powerlevel10k can remove Zsh startup lag **even if it's not caused by a theme**.

![Powerlevel10k Instant Prompt](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/instant-prompt.gif)

This feature is called _Instant Prompt_. You need to explicitly enable it through `p10k configure`
or [manually](../#how-do-i-enable-instant-prompt). It does what it says on the tin -- prints prompt
instantly upon Zsh startup allowing you to start typing while plugins are still loading.

Other themes _increase_ Zsh startup lag -- some by a lot, others by a just a little. Powerlevel10k
_removes_ it outright.

_FAQ:_ [How do I enable instant prompt?](#how-do-i-enable-instant-prompt)

## Show on command

The behavior of some commands depends on global environment. For example, `kubectl run ...` runs an
image on the cluster defined by the current kubernetes context. If you frequently change context
between "prod" and "testing", you might want to display the current context in Zsh prompt. If you do
likewise for AWS, Azure and Google Cloud credentials, prompt will get pretty crowded.

Enter _Show On Command_. This feature makes prompt segments appear only when they are relevant to
the command you are currently typing.

```zsh
# Show prompt segment "kubecontext" only when the command you are typing
# invokes kubectl, helm, kubens, kubectx, oc, istioctl, kogito, k9s or helmfile.
typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile'
```

![Powerlevel10k Show On Command](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/show-on-command.gif)

Configs created by `p10k configure` enable show on command for several prompt segments by default.
Here's the relevant parameter for kubernetes context:


To customize when different prompt segments are shown, open `~/.p10k.zsh`, search for
`SHOW_ON_COMMAND` and either remove these parameters to display affected segments unconditionally,
or change their values.

## Transient prompt

When _Transient Prompt_ is enabled through `p10k configure`, Powerlevel10k will trim down every
prompt when accepting a command line.

![Powerlevel10k Transient Prompt](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/transient-prompt.gif)

Transient prompt makes it much easier to copy-paste series of commands from the terminal scrollback.

_Tip_: If you enable transient prompt, take advantage of two-line prompt. You'll get the benefit of
extra space for typing commands without the usual drawback of reduced scrollback density. Sparse
prompt (with an empty line before prompt) also works great in combination with transient prompt.

## Current directory that just works

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

_Troubleshooting_: [Directory is difficult to see in prompt when using Rainbow style.](#directory-is-difficult-to-see-in-prompt-when-using-rainbow-style)

## Extremely customizable

Powerlevel10k can be configured to look like any other Zsh theme out there.

![Powerlevel10k Other Theme Emulation](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/other-theme-emulation.gif)

[Pure](#pure-compatibility), [Powerlevel9k](p9k_compatibility.md) and [robbyrussell](#how-to-make-powerlevel10k-look-like-robbyrussell-oh-my-zsh-theme) emulations are built-in.
To emulate the appearance of other themes, you'll need to write a suitable configuration file. The
best way to go about it is to run `p10k configure`, select the style that is the closest to your
goal and then edit `~/.p10k.zsh`.

The full range of Powerlevel10k appearance spans from spartan:

![Powerlevel10k Spartan Style](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/spartan-style.png)

To ~~ridiculous~~ extravagant:

![Powerlevel10k Extravagant Style](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/extravagant-style.png)

## Batteries included

Powerlevel10k comes with dozens of built-in high quality segments. When you run `p10k configure`
and choose any style except [Pure](#pure-compatibility), many of these segments get enabled by
default while others be manually enabled by opening `~/.p10k.zsh` and uncommenting them. You can
enable as many segments as you like. It won't slow down your prompt or Zsh startup.

|                  Segment | Meaning                                                                                                                                                        |
| -----------------------: | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|                `os_icon` | your OS logo (apple for macOS, swirl for debian, etc.)                                                                                                         |
|                    `dir` | current working directory                                                                                                                                      |
|                    `vcs` | Git repository status                                                                                                                                          |
|            `prompt_char` | multi-functional prompt symbol; changes depending on vi mode: `❯`, `❮`, `V`, `▶` for insert, command, visual and replace mode respectively; turns red on error |
|                `context` | user@hostname                                                                                                                                                  |
|                 `status` | exit code of the last command                                                                                                                                  |
| `command_execution_time` | duration (wall time) of the last command                                                                                                                       |
|        `background_jobs` | presence of background jobs                                                                                                                                    |
|                   `time` | current time                                                                                                                                                   |
|                 `direnv` | [direnv](https://direnv.net/) status                                                                                                                           |
|                   `asdf` | tool versions from [asdf](https://github.com/asdf-vm/asdf)                                                                                                     |
|             `virtualenv` | python environment from [venv](https://docs.python.org/3/library/venv.html)                                                                                    |
|               `anaconda` | virtual environment from [conda](https://conda.io/)                                                                                                            |
|                  `pyenv` | python environment from [pyenv](https://github.com/pyenv/pyenv)                                                                                                |
|                  `goenv` | go environment from [goenv](https://github.com/syndbg/goenv)                                                                                                   |
|                 `nodenv` | node.js environment from [nodenv](https://github.com/nodenv/nodenv)                                                                                            |
|                    `nvm` | node.js environment from [nvm](https://github.com/nvm-sh/nvm)                                                                                                  |
|                `nodeenv` | node.js environment from [nodeenv](https://github.com/ekalinin/nodeenv)                                                                                        |
|                  `rbenv` | ruby environment from [rbenv](https://github.com/rbenv/rbenv)                                                                                                  |
|                    `rvm` | ruby environment from [rvm](https://rvm.io)                                                                                                                    |
|                    `fvm` | flutter environment from [fvm](https://github.com/leoafarias/fvm)                                                                                              |
|                 `luaenv` | lua environment from [luaenv](https://github.com/cehoffman/luaenv)                                                                                             |
|                   `jenv` | java environment from [jenv](https://github.com/jenv/jenv)                                                                                                     |
|                  `plenv` | perl environment from [plenv](https://github.com/tokuhirom/plenv)                                                                                              |
|                 `phpenv` | php environment from [phpenv](https://github.com/phpenv/phpenv)                                                                                                |
|          `haskell_stack` | haskell version from [stack](https://haskellstack.org/)                                                                                                        |
|           `node_version` | [node.js](https://nodejs.org/) version                                                                                                                         |
|             `go_version` | [go](https://golang.org) version                                                                                                                               |
|           `rust_version` | [rustc](https://www.rust-lang.org) version                                                                                                                     |
|         `dotnet_version` | [dotnet](https://dotnet.microsoft.com) version                                                                                                                 |
|            `php_version` | [php](https://www.php.net/) version                                                                                                                            |
|        `laravel_version` | [laravel php framework](https://laravel.com/) version                                                                                                          |
|           `java_version` | [java](https://www.java.com/) version                                                                                                                          |
|                `package` | `name@version` from [package.json](https://docs.npmjs.com/files/package.json)                                                                                  |
|            `kubecontext` | current [kubernetes](https://kubernetes.io/) context                                                                                                           |
|              `terraform` | [terraform](https://www.terraform.io) workspace                                                                                                                |
|                    `aws` | [aws profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)                                                                    |
|             `aws_eb_env` | [aws elastic beanstalk](https://aws.amazon.com/elasticbeanstalk/) environment                                                                                  |
|                  `azure` | [azure](https://docs.microsoft.com/en-us/cli/azure) account name                                                                                               |
|                 `gcloud` | [google cloud](https://cloud.google.com/) cli account and project                                                                                              |
|        `google_app_cred` | [google application credentials](https://cloud.google.com/docs/authentication/production)                                                                      |
|                `nordvpn` | [nordvpn](https://nordvpn.com/) connection status                                                                                                              |
|                 `ranger` | [ranger](https://github.com/ranger/ranger) shell                                                                                                               |
|                    `nnn` | [nnn](https://github.com/jarun/nnn) shell                                                                                                                      |
|              `vim_shell` | [vim](https://www.vim.org/) shell (`:sh`)                                                                                                                      |
|     `midnight_commander` | [midnight commander](https://midnight-commander.org/) shell                                                                                                    |
|              `nix_shell` | [nix shell](https://nixos.org/nixos/nix-pills/developing-with-nix-shell.html) indicator                                                                        |
|                   `todo` | [todo](https://github.com/todotxt/todo.txt-cli) items                                                                                                          |
|            `timewarrior` | [timewarrior](https://timewarrior.net/) tracking status                                                                                                        |
|            `taskwarrior` | [taskwarrior](https://taskwarrior.org/) task count                                                                                                             |
|                 `vpn_ip` | virtual private network indicator                                                                                                                              |
|                     `ip` | IP address and bandwidth usage for a specified network interface                                                                                               |
|                   `load` | CPU load                                                                                                                                                       |
|             `disk_usage` | disk usage                                                                                                                                                     |
|                    `ram` | free RAM                                                                                                                                                       |
|                   `swap` | used swap                                                                                                                                                      |
|              `public_ip` | public IP address                                                                                                                                              |
|                  `proxy` | system-wide http/https/ftp proxy                                                                                                                               |
|                   `wifi` | WiFi speed                                                                                                                                                     |
|                `battery` | internal battery state and charge level (yep, batteries _literally_ included)                                                                                  |

## Extensible

If there is no prompt segment that does what you need, implement your own. Powerlevel10k provides
public API for defining segments that are as fast and as flexible as built-in ones.

![Powerlevel10k Custom Segment](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/custom-segment.gif)

On Linux you can fetch current CPU temperature by reading `/sys/class/thermal/thermal_zone0/temp`.
The screencast shows how to define a prompt segment to display this value. Once the segment is
defined, you can use it like any other segment. All standard customization parameters will work for
it out of the box.

Type `p10k help segment` for reference.

_Tip_: Prefix names of your own segments with `my_` to avoid clashes with future versions of
Powerlevel10k.
