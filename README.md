### The "arch-configurator"

#### Instructions

A little setup script for my typical arch install.

1. Install Arch as you like it.

2. Clone this repository into /root/

3. Be sure to read config.sh, to be clear what it exactly does. It set an comment `Starting point` to search for the beginning of the actual script.

4. If everything is ok with you, run config.sh and follow the instructions.

#### Explanation

config.sh

> Lays down the foundtion for the user.

sync-dotfiles.sh

> Sets up the `dfr`-alias and a bare git repository, which both are needed for
> synchronizing config and dotfiles between several linux machines.
> Changes will just be done in the scope of $HOME. No system files are touched.

packages-list.txt

> Stores the packages names, for `config.sh` to loop over it.
> Be sure that there are NO blank lines.
