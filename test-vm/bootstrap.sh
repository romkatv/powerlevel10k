#!/bin/sh

#sudo apt-get update

sudo apt-get install -y curl
sudo apt-get install -y git

sudo apt-get install -y zsh
sudo chsh -s $(which zsh) vagrant

# Install mercurial
sudo apt-get install -y mercurial
# Install Subversion
sudo apt-get install -y subversion
# install golang
echo 'golang-go golang-go/dashboard boolean false' | sudo debconf-set-selections
sudo apt-get install -y golang
# Install dependencies for tests
sudo apt-get install -y jq node ruby python python-virtualenv