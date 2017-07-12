#!/bin/zsh

mkdir ~/antigen

curl \
  -qLsSf \
  -o ~/antigen/antigen.zsh \
  https://git.io/antigen

source ~/antigen/antigen.zsh

# EOF
