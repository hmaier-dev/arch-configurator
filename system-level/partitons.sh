#!/bin/bash

# read -e -p "" PROCEED 
# PROCCED=${PROCEED:-n}

echo -e "--------------------------------------------------------------------------"
echo -e "Lets partition your disks."
sleep 1
echo -e "A 512MB EFI-Partition and max. 250GB ROOT-Partition will get created."
sleep 1
echo -e "Run this script only on fresh installed systems."
echo -e "--------------------------------------------------------------------------\n"

sleep 2

lsblk
read -e -p "Which disk y"

