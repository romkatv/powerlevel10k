#!/usr/bin/zsh

echo 'LANG=en_US.UTF-8' >! ~/.zshrc
echo 'source /vagrant_data/powerlevel9k.zsh-theme' >> ~/.zshrc

# setup environment
/vagrant_data/test-vm-providers/setup-environment.sh