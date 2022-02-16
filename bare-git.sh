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

echo -e "Creating bare git repo..."
git config --global init.defaultBranch main
git init --bare /home/$u/repos/dotfiles
/usr/bin/git --git-dir=/home/$u/repos/dotfiles/ --work-tree=/home/$u config --local status.showUntrackedFiles no
/usr/bin/git --git-dir=/home/$u/repos/dotfiles/ --work-tree=/home/$u remote add origin git@github.com:hmaier-ipb/dotfiles.git

echo -e "Bare repo initalized!"
echo -e "Add your public ssh-key (~/.ssh/id_rsa.pub) to github for push/pull."
