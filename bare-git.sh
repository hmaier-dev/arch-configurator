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
/usr/bin/git --git-dir=/home/$u/repos/dotfiles/ --work-tree=/home/$u
remote add origin git@github.com:hmaier-ipb/dotfiles.git
#/usr/bin/git --git-dir=/home/$u/repos/dotfiles/ --work-tree=/home/$u branch --set-upstream-to=origin/main main

#echo -e "Adding your public ssh key to github..."
#read -p "Enter username for github: " user
#read -s -p "Enter password for github: " pass
#
#echo -e "Contacting the github-api...\n"
#
#curl -u "$user:$pass" --data '{"title":"$user@$hostname","key":"'"$(cat ~/.ssh/id_rsa.pub)"'"}' https://api.github.com/$user/keys
#

echo -e "Searching for public ssh-key..."

while [ ! -f /home/$u/.ssh/id_rsa.pub ]; do
	ssh-keygen
done

echo -e "Writing your public ssh-key to networkshare..."
cp /home/$u/.ssh/id_rsa.pub /home/$u/networkshare/hmaier/linux-files/public_ssh_key.txt

echo -e "Creating temporary DotFilesRepo (dfr) alias..."
alias dfr='/usr/bin/git --git-dir=/home/$u/repos/dotfiles/ --work-tree=/home/$u'

echo -e "Thank you for organizing dotfiles!"
