all:
	sudo nixos-rebuild switch -j auto && systemctl restart --user emanote

home:
	nix build --no-link ".#homeConfigurations."`whoami`@`hostname`".activationPackage"
	./result/activate

home2:
	PATH="${HOME}/.nix-profile/bin/:${PATH}" home-manager  switch
	
freeupboot:
	# Delete all but the last few generations
	sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5
	sudo nixos-rebuild boot
