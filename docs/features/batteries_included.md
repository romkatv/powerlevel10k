# Batteries included

Powerlevel10k comes with dozens of built-in high quality segments. When you run `p10k configure`
and choose any style except [Pure](pure_compatibility.md), many of these segments get enabled by
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
