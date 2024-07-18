## The "arch-configurator"

This collection of shell-scripts will guide me through a typical Arch-install.

### Instructions

At first, boot into the ISO and change the keyboard-layout with

* `loadkeys de`
* `loadkeys de-latin1`

After this step, you can clone this repo.
Everything in `system-level`, modifies the system and therefore must be run as root.
Changes to the user-profile are done by the scripts in `userland`. Do not run them as root.
For your own safety, read every script to understand what it does. 

You can now start with the installation.

1. Partition your system (with `cfdisk`, `mkfs.fat -F 32 -n <label>` and `mkfs.ext4 -L <label>`) and mount it for pacstrap.

2. Run `pacstrap -K /mnt base linux linux-firmware vim nvim`

3. Copy this repository from `/root` into `/mnt/root/`, so you can use the scripts on your first boot.

4. `arch-chroot` into `/mnt`. You can now setup the bootloader, network and the system itself.

