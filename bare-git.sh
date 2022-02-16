#!/bin/bash

echo -e "--------------------------------------------------------------"
echo -e "This script will setup a bare git repo, for managing dotfiles."
echo -e "Don't run this as root."
echo -e "--------------------------------------------------------------"

read -e -p "Continue with the script? [y/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
[ $PROCCED != "y" ] && exit

u=$USER
echo -e "Creating dotfile folder.."
mkdir -p /home/$u/repos/dotfiles

echo -e "Echoing dfr-alias to the bashrc..."
echo "alias dfr='/usr/bin/git --git-dir=$HOME/repos/dotfiles --working-tree=$HOME'" >> ~/.bashrc

echo "repos/dotfiles" >> .gitignore

echo -e "Creating bare git repo..."
git config --global init.defaultBranch main
git clone --bare git@github.com:hmaier-ipb/dotfiles.git $HOME/repos/dotfiles

/usr/bin/git --git-dir=$HOME/repos/dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no
/usr/bin/git --git-dir=$HOME/repos/dotfiles/ --work-tree=$HOME checkout

echo -e "Searching for public ssh-key..."
while [ ! -f /home/$u/.ssh/id_rsa.pub ]; do
	ssh-keygen
done

echo -e "Writing your public ssh-key to networkshare..."
cp /home/$u/.ssh/id_rsa.pub /home/$u/networkshare/hmaier/linux-files/public_ssh_key.txt

echo -e "Thank you for organizing dotfiles!"
