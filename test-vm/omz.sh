#!/usr/bin/zsh
# We need to run this script in ZSH, so that switching user works!
NEW_USER=vagrant-omz
# Create User
PASSWORD='$6$OgLg9v2Z$Db38Jr9inZG7y8BzL8kqFK23fF5jZ7FU1oiIBLFjNYR9XVX03fwQayMgA6Rm1rzLbXaf.gkZaTWhB9pv5XLq11'
sudo useradd -p $PASSWORD -g vagrant -s $(which zsh) -m $NEW_USER
echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$NEW_USER
chmod 440 /etc/sudoers.d/$NEW_USER

(
        # Change User (See http://unix.stackexchange.com/questions/86778/why-cant-we-execute-a-list-of-commands-as-different-user-without-sudo)
        USERNAME=$NEW_USER
        #UID=$(id -u $NEW_USER)
        #EUID=$(id -u $NEW_USER)
        HOME=/home/$NEW_USER

        curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

        cd ~/.oh-my-zsh/custom
        git clone https://github.com/bhilburn/powerlevel9k.git themes/powerlevel9k

        echo '
export ZSH=$HOME/.oh-my-zsh
plugins=(git bundler osx rake ruby)
ZSH_THEME="powerlevel9k/powerlevel9k"

source $ZSH/oh-my-zsh.sh
' > ~/.zshrc

)
