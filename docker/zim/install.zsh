#!zsh

git clone --recursive https://github.com/Eriner/zim.git "${ZDOTDIR:-${HOME}}/.zim"

setopt EXTENDED_GLOB
for template_file ( ${ZDOTDIR:-${HOME}}/.zim/templates/* ); do
  user_file="${ZDOTDIR:-${HOME}}/.${template_file:t}"
  touch ${user_file}
  ( print -rn "$(<${template_file})$(<${user_file})" >! ${user_file} ) 2>/dev/null
done

source "${ZDOTDIR:-${HOME}}/.zlogin"

ln -nsf \
  ~/p9k/ \
  ~/.zim/modules/prompt/external-themes/powerlevel9k
ln -nsf \
  ~/.zim/modules/prompt/external-themes/powerlevel9k/powerlevel9k.zsh-theme \
  ~/.zim/modules/prompt/functions/prompt_powerlevel9k_setup

sed -i "s/zprompt_theme='steeef'/zprompt_theme='powerlevel9k'/g" ~/.zimrc
