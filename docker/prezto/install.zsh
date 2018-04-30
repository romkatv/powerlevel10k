#!/bin/zsh

set -eu

git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -nsf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

ln -s "${HOME}/p9k/powerlevel9k.zsh-theme" \
  "${HOME}/.zprezto/modules/prompt/functions/prompt_powerlevel9k_setup"

echo "zstyle ':prezto:module:prompt' theme 'powerlevel9k'" \
  >> "${HOME}/.zpreztorc"

# EOF
