#!/bin/bash

shopt -s dotglob

echo -e "------------------------------------------------------------\n"
echo -e "Hello $USER!"
echo -e "This script will setup your default workspace."
echo -e "------------------------------------------------------------\n"

read -e -p "Continue with the script? [y/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
[ $PROCCED != "y" ] && exit

declare -a aur_programs=(
	"nerd-fonts-source-code-pro" # This font is important for polybar. Can be replaced by community/ttf-sourcecodepro-nerd
	"brave-bin"
	"timeshift"
	"phpstorm"
	"pandoc-bin"
)

builds="/home/$USER/builds"

mkdir -p $builds

aur () {
	read -e -p "Do you really want to install $1 [y/n/q]" PROCEED 
	PROCCED=${PROCEED:-n}
	if [[ $PROCEED = "y" ]]; then
		echo -e "Installing program: $1"
		cd $builds
		git clone https://aur.archlinux.org/$1.git
		cd $1
		# add this for error suppression: >/dev/null 2>&1 
		makepkg --noconfirm -sic  
		cd $HOME
	fi
}

echo -e "Installing AUR programs..."

for i in ${aur_programs[@]}; do
	echo -e "Installing programm: $i ..."
	aur "$i"
done

echo -e "Thank you for installing useful programs!"
shopt -u dotglob # for don't considering dot files (turn off dot files)
