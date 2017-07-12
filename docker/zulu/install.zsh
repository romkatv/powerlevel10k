#!zsh

# install zulu https://github.com/zulu-zsh/zulu
curl -L https://git.io/zulu-install | zsh && zsh

{
echo 'zulu fpath add ~/p9k'
echo 'zulu fpath add ~/p9k/functions'
echo 'zulu theme powerlevel9k'
} >> ~/.zshrc
