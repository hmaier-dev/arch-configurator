#!/bin/bash

echo -e "------------------------------------------------------------"
echo -e "Welcome to self-configuring Arch!"
echo -e "Run this script only on fresh installed systems."
echo -e "It will install my dotfiles as well as config files for:"
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
connect_isilon () {
	echo -e "For access to the isilon domain credentials are needed."	
	read -p "Enter domain username: " uname
	read -s -p "Enter domain password: " password
	echo -e "\nCreating a credentials file..."
	touch /home/$username/.isilon_access
	echo "username=$uname" >> /home/$username/.isilon_access
	echo "pass=$password" >> /home/$username/.isilon_access
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
		echo -e "No connection to the networkshare. Delete line 65 to continue."
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

}

connect_fritz_nas () {
	echo -e "For connection the fritz nas your credentials are needed."
	read -p "Enter nas username: " uname
	read -s -p "Enter nas password: " password

	echo -e "\nCreating a credentials file..."
	touch /home/$username/.smbcredentials
	echo "username=$uname" >> /home/$username/.smbcredentials
	echo "pass=$password" >> /home/$username/.smbcredentials
	chmod 600 /home/$username/.smbcredentials # just root can read/write this file

	echo -e "Creating networkshare directorys..."
	mkdir -p /home/$username/networkshare

	p "cifs-utils"

	echo -e "Creating custom mount-units..."
	touch /etc/systemd/system/home-$username-networkshare.mount
	touch /etc/systemd/system/home-$username-networkshare.automount
	echo -e "Writing home-$username-networkshare.mount"
	echo -e "[Unit]\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "Description=the fritz nas on our wlan-repeater\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "Wants=network-online.target\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "After=network-online.target\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "[Mount]\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "What=//192.168.178.99/nas/private_hdd\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "Where=/home/$username/networkshare\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "Type=cifs\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "Options=credentials=/home/hmaier/.smbcredentials,vers=2.1,noserverino,uid=1001,gid=1001\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "[Install]\n" >> /etc/systemd/system/home-$username-networkshare.mount
	echo -e "WantedBy=multi-user.target\n" >> /etc/systemd/system/home-$username-networkshare.mount

	echo -e "Writing home-$username-networkshare.automount"
	echo -e "[Unit]\n" >> /etc/systemd/system/home-$username-networkshare.automount
	echo -e "Description=Automount networkshare to home directory\n" >> /etc/systemd/system/home-$username-networkshare.automount
	echo -e "\n" >> /etc/systemd/system/home-$username-networkshare.automount
	echo -e "[Automount]\n" >> /etc/systemd/system/home-$username-networkshare.automount
	echo -e "Where=/home/hmaier/networkshare\n" >> /etc/systemd/system/home-$username-networkshare.automount
	echo -e "\n" >> /etc/systemd/system/home-$username-networkshare.automount
	echo -e "[Install]\n" >> /etc/systemd/system/home-$username-networkshare.automount
	echo -e "WantedBy=multi-user.target\n" >> /etc/systemd/system/home-$username-networkshare.automount
	
}

# Actual script starts!
# Starting point
# Beginning

read -p "Enter the hostname for this device: " hostname
read -p "Enter local username: " username
read -p "Enter preferred user id [1001]: " userid
userid=${userid:-1001}

echo -e "Creating User..."
useradd -m --uid 1001 -G wheel $username

echo -e "Changing password of $username"
passwd $username

read -e -p "Are you at [h]ome or at [w]ork? [h/w/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
if [[ $PROCCED = "w" ]]; then
	connect_isilon
fi
if [[ $PROCCED = "h"  ]]; then
	connect_fritz_nas
fi

echo -e "Copying script for dotfiles management..."
cd /root

cp /root/arch-configurator/sync-dotfiles.sh /home/$username
chown $username /home/$username/sync-dotfiles.sh
chmod +x /home/$username/sync-dotfiles.sh

echo -e "Copying script for workspace setup..."
cd /root

cp /root/arch-configurator/workspace-setup.sh /home/$username
chown $username /home/$username/workspace-setup.sh
chmod +x /home/$username/workspace-setup.sh

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

p "opendoas"
echo -e "Creating doas.conf"
touch /etc/doas.conf
echo "permit :wheel" >> /etc/doas.conf
echo "permit setenv { XAUTHORITY LANG LC_ALL } :wheel" >> /etc/doas.conf
echo "permit nopass hmaier as root cmd pacman" >> /etc/doas.conf
chown -c root:root /etc/doas.conf
chmod -c 0600 /etc/doas.conf

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
mkdir /home/$username/pics
chown $username /home/$username/pics
mkdir /home/$username/pics/screenshots
chown $username /home/$username/pics/screenshots

echo -e "Enabling lightdm display manager..."
systemctl enable lightdm --quiet
sed -i "/#greeter-session=/c\greeter-session=lightdm-gtk-greeter" /etc/lightdm/lightdm.conf
sed -i "/#display-setup-script=/c\display-setup-script=/usr/bin/setxkbmap de" /etc/lightdm/lightdm.conf
#sed -i "/#greeter-setup-script=/c\greeter-setup-script=/usr/bin/numlockx on" /etc/lightdm/lightdm.conf

echo -e "Configuring lightdm..."

cp /usr/share/pixmaps/archlinux-logo.png /etc/lightdm
if [ -f /etc/lightdm/lightdm-gtk-greeter.conf ];then
	rm /etc/lightdm/lightdm-gtk-greeter.conf
fi

touch /etc/lightdm/lightdm-gtk-greeter.conf
echo "[greeter]" >> /etc/lightdm/lightdm-gtk-greeter.conf
echo "background = #5e5c64 " >> /etc/lightdm/lightdm-gtk-greeter.conf
echo "default-user-image = /etc/lightdm/archlinux-logo.png" >> /etc/lightdm/lightdm-gtk-greeter.conf

echo -e "Changing the hostname of this device..."
sed -i "/#hostname/c\hostname=$hostname" /etc/dhcpcd.conf
echo $hostname > /etc/hostname
hostnamectl set-hostname $hostname

echo -e "\n"
echo -e "Now you can log in as $username!"
echo -e "For syncing your dotfiles, run ./sync-dotfiles.sh as $username."
echo -e "Thank you for running the arch-configurator!"

shopt -u dotglob # for don't considering dot files (turn off dot files)
