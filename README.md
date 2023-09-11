## The "arch-configurator"

This collection of shell-scripts will guide me through a typical Arch-install.

### Instructions

Boot right into the iso and clone this repo. 
Everything the `system-level`-folder must be done as root.
Read every script to know what it does.

1. Partition your system and mount it for pacstrap.

2. Run `pacstrap -K /mnt base linux linux-firmware vim nvim`

3. Clone this repository into `/mnt/root/`. 


### Roadmaps - Bullet-Point

- Automate `systemd-networkd` and `systemd-resolved` configuration in a single file
- Parition the system: 512M EFI + max. 250G ROOT
- Seperate configuration of network shares into a single file
- Implement idempotency (https://search.brave.com/search?q=idempotency), for multiple runs of a script producing the same output
- Automate the pre-installation in `arch-chroot` -> systemd-boot + dns (resolved) + dhcp (networkd)
