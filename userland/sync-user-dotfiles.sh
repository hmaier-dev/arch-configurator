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

#echo -e "Searching for public ssh-key..."
#while [ ! -f /home/$u/.ssh/id_rsa.pub ]; do
#	ssh-keygen
#done

echo -e "If you are at work, you can copy the public-key to your networkshare."
read -e -p "Do you want to write your ssh-key to networkshare? [y/n/p]" PROCEED 
if [ $PROCCED != "y" ];then
	echo -e "Writing your public ssh-key to networkshare..."
	cp /home/$u/.ssh/id_rsa.pub /home/$u/networkshare/hmaier/linux-files/public_ssh_key.txt
fi

read -e -p "Have you copied your public ssh-key to github? [y/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
[ $PROCCED != "y" ] && echo -e "Go do that!" && exit


git config --global user.email "hendrik_maier@protonmail.com"
git config --global user.name "Hendrik Maier"

#deleting existing dotfiles, so git checkout can happen (git does not remove file by itself)
echo -e "Removing already existing dotfiles..."
rm $HOME/.bashrc
rm $HOME/.bash_profile
rm $HOME/.config/user-dirs.dirs
rm $HOME/.profile
rm $HOME/.bash_aliases


echo -e "Creating dotfiles-repo folder.."
mkdir -p /home/$u/repos/dotfiles

echo "repos/dotfiles" >> .gitignore

echo -e "Creating bare git repo..."
git config --global init.defaultBranch main
git clone --bare git@github.com:hmaier-dev/dotfiles.git $HOME/repos/dotfiles

/usr/bin/git --git-dir=$HOME/repos/dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no
# without 'checkout' the dotfiles don't get copied... (I don't know why this works)
# /usr/bin/git --git-dir=$HOME/repos/dotfiles/ --work-tree=$HOME checkout

/usr/bin/git --git-dir=$HOME/repos/dotfiles/ --work-tree=$HOME fetch

echo -e "Printing out the current git status..."
/usr/bin/git --git-dir=$HOME/repos/dotfiles/ --work-tree=$HOME status


read -e -p "Do you want to pull your config files into \$HOME? [y/n/p]" PROCEED 
if [ $PROCCED != "y" ];then
	echo -e "Pulling..."
	/usr/bin/git --git-dir=$HOME/repos/dotfiles/ --work-tree=$HOME pull
	echo -e "Now checkout..."
	/usr/bin/git --git-dir=$HOME/repos/dotfiles/ --work-tree=$HOME checkout
	echo -e "Setting upstream..."
	/usr/bin/git --git-dir=$HOME/repos/dotfiles/ --work-tree=$HOME push --set-upstream origin main
fi

echo -e "When tracking file into the dotfiles repo, use the alias dfr instead of git."
echo -e "git -> dfr"
echo -e "\n"
echo -e "If something didn't work use this!"
echo -e "/usr/bin/git --git-dir=$HOME/repos/dotfiles/ --work-tree=$HOME"
echo -e "\n"
echo -e "Thank you for organizing dotfiles!"

