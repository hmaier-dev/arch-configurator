#!/bin/bash

echo -e "------------------------------------------------------------"
echo -e "Welcome to \"setting-up-the-network\" on Arch!"
echo -e "Run this before your first boot in arch-chroot."
echo -e "------------------------------------------------------------\n"

if [[ $EUID -ne 0  ]]; then
	echo "Run this as root."
	exit 1
fi

read -e -p "Continue with the script? [y/n/q]" FORWARD
FORWARD=${FORWARD:-n}
[ $FORWARD != "y" ] && exit

echo -e "Setting up dhcp and dns..."
systemctl enable systemd-networkd
systemctl enable systemd-resolved
FORWARD=n
while [ "$FORWARD" == "n" ]; do
	ip addr
	ip link show
	echo -e "The usual interface-name will look like eno1, eth1, enp8s0 etc..."
	read -p "Please enter the name of your connected interface: " interface
	read -e -p "Is this interface name correct: $interface? [y/n]" FORWARD
	FORWARD=${FORWARD:-n}
done

touch /etc/systemd/network/20-wired.network
echo "[Match]" >> /etc/systemd/network/20-wired.network
echo "Name=$interface " >> /etc/systemd/network/20-wired.network
echo " " >> /etc/systemd/network/20-wired.network
echo "[Network]" >> /etc/systemd/network/20-wired.network
echo "DHCP=yes" >> /etc/systemd/network/20-wired.network

systemctl restart systemd-networkd
systemctl restart systemd-resolved
