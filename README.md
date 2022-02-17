### The "arch-configurator"
A little setup script for my typical arch install. 

1. Install Arch as you like it.

2. Clone this repository into /root/

3. Run config.sh and follow the instructions.

	- config.sh
	-> Run this script as root. It create a user, copys differnt automount units and installs packages. After running this script basic configuration is done.

	- sync-dotfiles.sh
	-> Run this in the home directory of your new user. It creates a bare git repo, for syncing config-/dotfiles on different machines.

	- packages-list.txt
	-> No AUR packages. Is read by config.sh.
