#!/bin/bash

# read -e -p "" PROCEED 
# PROCCED=${PROCEED:-n}

echo -e "--------------------------------------------------------------------------"
echo -e "Lets partition your disks."
echo -e "A 512MB EFI-Partition and max. 250GB ROOT-Partition will get created."
echo -e "Run this script only on fresh installed systems."
echo -e "--------------------------------------------------------------------------\n"

if [[ $EUID -ne 0  ]]; then
	echo "Run this as root."
	exit 1
fi

lsblk
read -e -p "Which disk you want to use?" disk

if [[ -e $disk ]];then ## -e means: file/dir exists
	echo "You selected $disk."
else
	echo "The disk $disk does not exist. Select a valid disk  (e.g., /dev/sdX)."
	exit 1
fi

(
	echo g # Create a new empty GPT partition table
	echo n # Add a new partition
	echo p # Primary partition
	echo 1 # Partition number
	echo   # First sector (Accept default: 1)
	echo   # Last sector (Accept default: varies)
	echo w # Write changes
) | fdisk
