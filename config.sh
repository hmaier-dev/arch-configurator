#!/bin/bash

echo -e "------------------------------------------------------------"
echo -e "Welcome to self-configuring Arch!"
echo -e "Run this script only on fresh installed systems."
echo -e "It will install my dotfiles as well as config file for:"
echo -e "bspwm,sxhkd,neovim"
echo -e "------------------------------------------------------------\n"

shopt -s dotglob # for considering dot files (turn on dot files)

read -e -p "Continue with the script? [y/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
[ $PROCCED != "y" ] && exit

# no need to accept a package, don't reinstall already up to date programms, quieten the output
p () { 
	echo -e "Installing package: $1"
	pacman --noconfirm --needed -S $1 >/dev/null 2>&1
}

read -p "Enter local username: " username

read -p "Enter preferred user id [1001]: " userid
userid=${userid:-1001}

echo -e "Creating User..."
useradd -m --uid 1001 -G wheel $username

echo -e "Changing password of $username"
passwd $username

read -p "Enter domain username: " uname
read -s -p "Enter domain password: " password


echo -e "\nCreating a credentials file..."
touch /home/$username/.isilon_access
echo "username=$uname" >> .isilon_access
echo "pass=$password" >> .isilon_access
chmod 600 /home/$username/.isilon_access # just root can read/write this file

echo -e "Creating networkshare directorys..."

mkdir -p /home/$username/networkshare
mkdir -p /home/$username/networkshare/$uname

echo -e "Connection to networkshare..."
# for mounting the networkshare, this package is needed
p "cifs-utils"

mount.cifs //isilon/Member_Home	/home/$username/networkshare/$uname -o pass=$password,user=$uname,uid=$userid,gid=$userid

if [ -d "/home/$username/networkshare/$uname/linux-files" ]; then
	echo -e "Successful connection to private networkshare!"
	mkdir -p /home/$username/networkshare/IPB
	mount.cifs //isilon/IPB	/home/$username/networkshare/IPB -o pass=$password,user=$uname,uid=$userid,gid=$userid
	mkdir -p /home/$username/networkshare/AdmIn
	mount.cifs //isilon/workspace /home/$username/networkshare/AdmIn -o pass=$password,user=$uname,uid=$userid,gid=$userid
	echo -e "Connected to public networkshares."	
else
	echo -e "No connection to the networkshare."
	exit
fi

echo -e "Copy unit-files for systemd-automount..."

# copying all mount and automount units
cp -r /home/$username/networkshare/$uname/linux-files/mounting-with-systemd /root
cp /root/mounting-with-systemd/* /etc/systemd/system 

#for network-online.target this unit has to be enabled
systemctl enable systemd-networkd.service --quiet
systemctl start systemd-networkd.service --quiet
# change the unit files "options=" individually?
cd /root/mounting-with-systemd/

for unit in *.automount;do
	echo -e "Enabling service for $unit."
	systemctl enable $unit --quiet
#	systemctl start $unit
done

echo -e "Copying script for dotfiles management..."
cd /root

cp /root/arch-configurator/sync-dotfiles.sh /home/$username
chown $username /home/$username/sync-dotfiles.sh
chmod +x /home/$username/sync-dotfiles.sh

echo -e "Base Configuration finished."

read -e -p "Continue with packages installation? [y/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
[ $PROCCED != "y" ] && exit

echo -e "Downloading packages..."
# take care: this will also read empty lines!
while read -r i; do
	p "$i"
done < /root/arch-configurator/packages-list.txt

#echo -e "Enabling lightdm display manager."
#systemctl enable lightdm --quiet

p "sudo"

# suoders file can just get changed when sudo is installed!
echo -e "Changing the sudoers file..."
sed -i '82i %wheel ALL=(ALL) ALL' /etc/sudoers
sed -i '83d' /etc/sudoers

echo -e "Creating .xinitrc..."
touch /home/$username/.xinitrc
chown $username /home/$username/.xinitrc

echo -e "Removing the beep sound..."
rmmod pcspkr
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

echo -e "Creating work directorys..."
mkdir /home/$username/Dokumente
chown $username /home/$username/Dokumente
mkdir /home/$username/Bilder
chown $username /home/$username/Bilder

echo -e "\n"
echo -e "Now you can log in as $username!"
echo -e "For syncing your dotfiles, run ./sync-dotfiles.sh as $username."
echo -e "Thank you for running the arch-configurator!"

shopt -u dotglob # for don't considering dot files (turn off dot files)
