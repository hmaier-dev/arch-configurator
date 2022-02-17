#!/bin/bash

echo -e "--------------------------------------------------------------"
echo -e "This script will setup a bare git repo, for managing dotfiles."
echo -e "Don't run this as root."
echo -e "Also beware: this will overwrite existing dotfiles!"
echo -e "--------------------------------------------------------------"

read -e -p "Continue with the script? [y/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
[ $PROCCED != "y" ] && exit

u=$USER

echo -e "Searching for public ssh-key..."
while [ ! -f /home/$u/.ssh/id_rsa.pub ]; do
	ssh-keygen
done

echo -e "Writing your public ssh-key to networkshare..."
cp /home/$u/.ssh/id_rsa.pub /home/$u/networkshare/hmaier/linux-files/public_ssh_key.txt

read -e -p "Have you copied your public ssh-key to github? [y/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
[ $PROCCED != "y" ] && echo -e "Go do that!" && exit

read -p "Enter your email (for git): " email
read -p "Enter your email (for git): " name

git config --global user.email "$email"
git config --global user.name "$name"

#deleting generated bashrc to prevent errors
rm $HOME/.bashrc

echo -e "Creating dotfile folder.."
mkdir -p /home/$u/repos/dotfiles

echo "repos/dotfiles" >> .gitignore

echo -e "Creating bare git repo..."
git config --global init.defaultBranch main
git clone --bare git@github.com:hmaier-ipb/dotfiles.git $HOME/repos/dotfiles

/usr/bin/git --git-dir=$HOME/repos/dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no
# without 'checkout' the dotfiles don't get copied... (I don't know why this works)
/usr/bin/git --git-dir=$HOME/repos/dotfiles/ --work-tree=$HOME checkout


echo -e "When tracking file into the dotfiles repo, use the alias dfr instead of git."
echo -e "git -> dfr"
echo -e "Thank you for organizing dotfiles!"

