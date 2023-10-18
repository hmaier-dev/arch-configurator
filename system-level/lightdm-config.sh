#!/bin/bash
#
if [ -d "/etc/lightdm" ]; then
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
fi
