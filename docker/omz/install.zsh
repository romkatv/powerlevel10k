sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

mkdir -p ~/.oh-my-zsh/custom/themes
ln -nsf ~/p9k/ ~/.oh-my-zsh/custom/themes/powerlevel9k
