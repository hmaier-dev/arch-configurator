## The "arch-configurator"

### Instructions

---

1. Partition and `pacstrap` your system.

2. Clone this repository into `/root/`. 

### Explanation

---

config.sh

> Everything user-based will configured here.

sync-dotfiles.sh

> Sets up the `dfr`-alias and a bare git repository, which both are needed for
> synchronizing config and dotfiles between several linux machines.
> Changes will just be done in the scope of $HOME. No system files are touched.

packages-list.txt

> Stores the packages names, for `config.sh` to loop over it.
> Be sure that there are **NO blank lines**.

aur-install.sh

> This installs some AUR-programs, as well as the AstroNvim distro for Neovim.
> Creates `$HOME\builds` for self-build programs.

network.sh
> Enables DNS and DHCP as systemd-services.

share.sh
> Setup known networkshares.


### Roadmaps - Bullet-Point

- Automate `systemd-networkd` and `systemd-resolved` configuration in a single file
- Seperate configuration of network shares into a single file
- Implement idempotency (https://search.brave.com/search?q=idempotency), for multiple runs of a script producing the same output
- Automate the pre-installation in `arch-chroot` -> systemd-boot + dns (resolved) + dhcp (networkd)
