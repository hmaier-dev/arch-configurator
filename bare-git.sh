#!/bin/bash

echo -e "--------------------------------------------------------------"
echo -e "This script will setup a bare git repo, for managing dotfiles."
echo -e "Don't run this as root."
echo -e "--------------------------------------------------------------"

read -e -p "Continue with the script? [y/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
[ $PROCCED != "y" ] && exit

u=$USER

mkdir -p /home/$u/repos/dotfiles
git config --global init.defaultBranch main
git init --bare /home/$u/repos/dotfiles
/usr/bin/git --git-dir=/home/$u/repos/dotfiles/ --work-tree=/home/$u config --local status.showUntrackedFiles no
