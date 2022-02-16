#!/bin/bash

echo -e "------------------------------------------------------------"
echo -e "Welcome to self-configuring Arch!"
echo -e "Run this script only on fresh installed systems."
echo -e "------------------------------------------------------------\n"

read -e -p "Continue with the script? [y/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
[ $PROCCED != "y" ] && exit

p () {
	pacman --noconfirm -S $1
}

read -p "Enter local username: " username

read -p "Enter preferred user id [1001]: " userid
userid=${userid:-1001}

read -p "Enter domain username: " uname
read -s -p "Enter domain password: " password

echo -e "Creating User..."
useradd -m --uid 1001 -G wheel $username

echo -e "Changing password of $username"
passwd $username

echo -e "Creating networkshare directorys..."

mkdir -p /home/$username/networkshare
mkdir -p /home/$username/networkshare/$uname

echo -e "Connection to networkshare..."

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
cp -r /home/$username/networkshare/$uname/linux-files/mounting-with-systemd /root
cp /root/mounting-with-systemd/* /etc/systemd/system 
#for network-online.target this unit has to be enabled
systemctl enable systemd-networkd.service
systemctl start systemd-networkd.service
cd /root/mounting-with-systemd/

for unit in *.automount;do
	systemctl enable $unit
	systemctl start $unit
done



#echo -e "Downloading packages..."
## take care: this will also read empty lines!
#while read -r i; do
#	p "$i"
#done < /home/$username/networkshare/$uname/linux-files/packages-list.txt
#
#
##create a repo online
#echo -e "Copying config files..."
#
#
