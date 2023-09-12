## The "arch-configurator"

### Instructions

---

1. Partition and `pacstrap` your system.

2. Clone this repository into `/root/`. 


### Roadmaps - Bullet-Point

- Automate `systemd-networkd` and `systemd-resolved` configuration in a single file
- Seperate configuration of network shares into a single file
- Implement idempotency (https://search.brave.com/search?q=idempotency), for multiple runs of a script producing the same output
- Automate the pre-installation in `arch-chroot` -> systemd-boot + dns (resolved) + dhcp (networkd)
