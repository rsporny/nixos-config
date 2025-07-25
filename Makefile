# Connectivity info for Linux VM
NIXADDR ?= nixos
NIXPORT ?= 22
NIXUSER ?= rspo

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# The name of the nixosConfiguration in the flake
NIXNAME ?= nixos

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# run this to finalize. After this, do everything else
# in the VM unless secrets change.
vm/bootstrap:
	NIXUSER=root $(MAKE) vm/copy
	NIXUSER=root $(MAKE) vm/switch
	$(MAKE) vm/clean
	$(MAKE) vm/secrets
	NIXUSER=root ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "sudo reboot"

# copy our secrets into the VM
vm/secrets:
	# GPG keyring
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='.#*' \
		--exclude='S.*' \
		--exclude='*.conf' \
		$(HOME)/.gnupg/ $(NIXUSER)@$(NIXADDR):~/.gnupg
	# SSH keys
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh

# clone repo with nix configuration files
vm/clone:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		git clone git@github.com:rsporny/nixos-config.git ~/work/repos/nix-config \
	"

# copy the Nix configurations into the VM.
vm/copy:
	rsync -av --delete -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='vendor/' \
		--exclude='.git/' \
		--exclude='.git-crypt/' \
		--exclude='.jj/' \
		--exclude='iso/' \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nix-config

# remove backup files
vm/clean:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		find ~/ -name \"*.backup\" -exec rm {} \; \
        "

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run vm/copy before.
vm/switch:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo nixos-rebuild switch --flake \"/nix-config#${NIXNAME}\" \
	"

