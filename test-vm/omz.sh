#!/usr/bin/zsh
# We need to run this script in ZSH, so that switching user works!
NEW_USER=vagrant-omz
# Create User
PASSWORD='$6$OgLg9v2Z$Db38Jr9inZG7y8BzL8kqFK23fF5jZ7FU1oiIBLFjNYR9XVX03fwQayMgA6Rm1rzLbXaf.gkZaTWhB9pv5XLq11'
useradd -p $PASSWORD -g vagrant -s $(which zsh) -m $NEW_USER
echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$NEW_USER
chmod 440 /etc/sudoers.d/$NEW_USER

(
        # Change User (See http://unix.stackexchange.com/questions/86778/why-cant-we-execute-a-list-of-commands-as-different-user-without-sudo)
        USERNAME=$NEW_USER
        #UID=$(id -u $NEW_USER)
        #EUID=$(id -u $NEW_USER)
        HOME=/home/$NEW_USER
	SHELL=$(which zsh)

        sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

        mkdir -p ~/.oh-my-zsh/custom/themes
        ln -s /vagrant_data ~/.oh-my-zsh/custom/themes/powerlevel9k

        echo '
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="powerlevel9k/powerlevel9k"
plugins=(git rake ruby)

source $ZSH/oh-my-zsh.sh
' > $HOME/.zshrc

        # setup environment
        /vagrant_data/test-vm-providers/setup-environment.sh
)
