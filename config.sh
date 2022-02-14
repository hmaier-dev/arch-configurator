#!/bin/bash

echo -e "------------------------------------------------------------\n"
echo -e "Welcome to self-configuring Arch!\n"
echo -e "Run this script only on fresh installed systems."
echo -e "------------------------------------------------------------\n"

read -e -p "Continue with the script? [y/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
[ $PROCCED != "y" ] && exit

p () {
	pacman --noconfirm -S $1
}

read -p "Enter local username: " username
echo -e "\n"

read -p "Enter preferred user id [1001]: " userid
userid=${userid:-1001}
echo -e "\n"

read -p "Enter domain username: " uname
read -s -p "Enter domain password: " password

echo -e "Creating User..."
useradd -m --uid 1001 -G wheel $username
echo -e "\n"

echo -e "Changing password of $username"
passwd $username
echo -e "\n"

echo -e "Creating networkshare directorys..."

mkdir -p /home/$username/networkshare
mkdir -p /home/$username/networkshare/$uname

echo -e "Connection to networkshare..."

p "cifs-utils"

mount.cifs //isilon/Member_Home	/home/$username/networkshare/$uname -o pass=$password,user=$uname,uid=$userid,gid=$userid

if [ -d "/home/$username/networkshare/$uname/linux-files" ]; then
	echo -e "Successful connection to the networkshare!"
	mkdir -p /home/$username/networkshare/IPB
	mount.cifs //isilon/IPB	/home/$username/networkshare/IPB -o pass=$password,user=$uname,uid=$userid,gid=$userid
	mkdir -p /home/$username/networkshare/AdmIn
	mount.cifs //isilon/workspace /home/$username/networkshare/AdmIn -o pass=$password,user=$uname,uid=$userid,gid=$userid

else
	echo -e "No connection to the networkshare."
	exit
fi

