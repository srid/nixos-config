all:
	sudo nixos-rebuild switch && systemctl restart --user emanote
	
	
freeupboot:
	# Delete all but the last few generations
	sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5
	sudo nixos-rebuild boot
