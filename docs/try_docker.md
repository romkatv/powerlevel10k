# Try it in Docker

Try Powerlevel10k in Docker. You can safely make any changes to the file system while trying out
the theme. Once you exit Zsh, the image is deleted.

```zsh
docker run -e TERM -e COLORTERM -it --rm alpine sh -uec '
  apk update
  apk add git zsh nano vim
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo "source ~/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc
  cd ~/powerlevel10k
  exec zsh'
```

_Tip_: Install [the recommended font](#meslo-nerd-font-patched-for-powerlevel10k) before
running the Docker command to get access to all prompt styles.

_Tip_: Run `p10k configure` while in Docker to try a different prompt style.
