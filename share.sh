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
