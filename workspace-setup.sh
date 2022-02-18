#!/bin/bash

shopt -s dotglob

echo -e "------------------------------------------------------------\n"
echo -e "Hello $USER!"
echo -e "This script will setup your default workspace."
echo -e "It will setup (n)vim and install AUR/git-packages like:"
echo -e "brave-bin, timeshift, polybar"
echo -e "------------------------------------------------------------\n"

read -e -p "Continue with the script? [y/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
[ $PROCCED != "y" ] && exit

declare -a programs=(
	"polybar"
	"brave-bin"
	"timeshift"
	"phpstorm"
)

mkdir -p $HOME/builds

aur () {
	echo -e "Installing program: $1"
  	cd $HOME/builds
	git clone https://aur.archlinux.org/$1.git
	cd $1
	makepkg --noconfirm -sic >/dev/null 2>&1 
	cd $HOME
}

echo -e "Downloading vim-plug..."
mkdir -p $HOME/.config/nvim/plugged

curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo -e "Installing AUR programs..."

for i in ${programs[@]}; do
	echo -e "Installing programm: $i ..."
	aur "$i"
done

echo -e "Thank you for installing useful programs!"
shopt -u dotglob # for don't considering dot files (turn off dot files)
