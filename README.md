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

1. Partition your system and mount it for pacstrap.

2. Run `pacstrap -K /mnt base linux linux-firmware vim nvim`

3. Copy this repository into `/mnt/root/`. 

4. `arch-chroot` into `/mnt`. You can now setup the bootloader, network and the system itself.


### Roadmaps - Bullet-Point

- Automate `systemd-networkd` and `systemd-resolved` configuration in a single file
- Parition the system: 512M EFI + max. 250G ROOT
- Seperate configuration of network shares into a single file
- Implement idempotency (https://search.brave.com/search?q=idempotency), for multiple runs of a script producing the same output
- Automate the pre-installation in `arch-chroot` -> systemd-boot + dns (resolved) + dhcp (networkd)
