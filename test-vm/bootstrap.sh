#!/bin/sh

#sudo apt-get update

sudo apt-get install -y curl
sudo apt-get install -y git

sudo apt-get install -y zsh
sudo chsh -s $(which zsh) vagrant
