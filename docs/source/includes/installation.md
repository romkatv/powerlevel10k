# Installation

1. Install [the recommended font](#recommended-font-meslo-nerd-font-patched-for-powerlevel10k). _Optional but highly
   recommended._
2. Install Powerlevel10k for your plugin manager.
   - [Manual](#manual) 👈 **choose this if confused or uncertain**
   - [Oh My Zsh](#oh-my-zsh)
   - [Prezto](#prezto)
   - [Zim](#zim)
   - [Antibody](#antibody)
   - [Antigen](#antigen)
   - [Zplug](#zplug)
   - [Zgen](#zgen)
   - [Zplugin](#zplugin)
   - [Zinit](#zinit)
   - [Homebrew](#homebrew)
   - [Arch Linux](#arch-linux)
3. Restart Zsh.
4. Type `p10k configure` if the configuration wizard doesn't start automatically.

## Manual

```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
```

Users in mainland China can use the official mirror on gitee.com for faster download.<br>
中国大陆用户可以使用 gitee.com 上的官方镜像加速下载.

```zsh
git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
```

This is the simplest kind of installation and it works even if you are using a plugin manager. Just
make sure to disable the current theme in your plugin manager. See
[troubleshooting](#cannot-make-powerlevel10k-work-with-my-plugin-manager) for help.

## Oh My Zsh

```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Users in mainland China can use the official mirror on gitee.com for faster download.<br>
中国大陆用户可以使用 gitee.com 上的官方镜像加速下载.

```zsh
git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Set `ZSH_THEME="powerlevel10k/powerlevel10k"` in `~/.zshrc`.

## Prezto

Add `zstyle :prezto:module:prompt theme powerlevel10k` to `~/.zpreztorc`.

## Zim

Add `zmodule romkatv/powerlevel10k` to `~/.zimrc` and run `zimfw install`.

## Antibody

Add `antibody bundle romkatv/powerlevel10k` to `~/.zshrc`.

## Antigen

Add `antigen theme romkatv/powerlevel10k` to `~/.zshrc`. Make sure you have `antigen apply`
somewhere after it.

## Zplug

Add `zplug romkatv/powerlevel10k, as:theme, depth:1` to `~/.zshrc`.

## Zgen

Add `zgen load romkatv/powerlevel10k powerlevel10k` to `~/.zshrc`.

## Zplugin

Add `zplugin ice depth=1; zplugin light romkatv/powerlevel10k` to `~/.zshrc`.

The use of `depth=1` ice is optional. Other types of ice are neither recommended nor officially
supported by Powerlevel10k.

## Zinit

Add `zinit ice depth=1; zinit light romkatv/powerlevel10k` to `~/.zshrc`.

The use of `depth=1` ice is optional. Other types of ice are neither recommended nor officially
supported by Powerlevel10k.

## Homebrew

```zsh
brew install romkatv/powerlevel10k/powerlevel10k
echo 'source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
```

## Arch Linux

```zsh
yay -S --noconfirm zsh-theme-powerlevel10k-git
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
```

[zsh-theme-powerlevel10k-git](https://aur.archlinux.org/packages/zsh-theme-powerlevel10k-git/)
referenced above is the official Powerlevel10k package.

There is also [zsh-theme-powerlevel10k](https://www.archlinux.org/packages/community/x86_64/zsh-theme-powerlevel10k/) community package.
Historicaly, [it has been breaking often and for extended periods of time](https://github.com/romkatv/powerlevel10k/pull/786). **Do not use it.**
