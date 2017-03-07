#!/bin/sh

# Install ZSH
sudo pkg install -y zsh
sudo chsh -s `which zsh` vagrant

# Install git
sudo pkg install -y git