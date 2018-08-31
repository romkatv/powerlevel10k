#!zsh

# install zshing https://github.com/zakariaGatter/zshing
git clone https://github.com/zakariaGatter/zshing.git ~/.zshing/zshing

# Link P9K in zshing directory
ln -nsf ~/p9k ~/.zshing/powerlevel9k

{
  echo
  echo 'ZSHING_PLUGINS=(
     "bhilburn/powerlevel9k"
 )'
  echo
  echo "source ~/.zshing/zshing/zshing.zsh"
} >> ~/.zshrc
