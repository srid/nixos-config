
all:
	@if [[ -d "/etc/nixos" ]]; then  \
		make nixos;\
	else \
		make h;\
	fi

nixos:
	sudo nixos-rebuild switch -j auto 
	systemctl restart --user emanote

# Not sure why this doesn't reliably work
h0:
	nix build ".#homeConfigurations."`hostname`".activationPackage"
	./result/activate

# This requires the symlink to be setup; see README
h:
	PATH="${HOME}/.nix-profile/bin/:${PATH}" home-manager  switch
	
freeupboot:
	# Delete all but the last few generations
	sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5
	sudo nixos-rebuild boot
