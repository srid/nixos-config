include /etc/lsb-release
export $(shell sed 's/=.*//' /etc/lsb-release)

all:
	# FIXME: Should just check for nixos instead.
	@if [ "${DISTRIB_ID}" = "Ubuntu" ]; then  \
		make home;\
	else \
		make nixos;\
	fi

nixos:
	sudo nixos-rebuild switch -j auto 
	systemctl restart --user emanote

# Not sure why this doesn't reliably work
homeBroken:
	nix build --no-link ".#homeConfigurations."`whoami`@`hostname`".activationPackage"
	./result/activate

# This requires the symlink to be setup; see README
home:
	PATH="${HOME}/.nix-profile/bin/:${PATH}" home-manager  switch
	
freeupboot:
	# Delete all but the last few generations
	sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5
	sudo nixos-rebuild boot
