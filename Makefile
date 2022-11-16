all:
	echo

# Update the primary inputs
#
# Typically run as: `make update && nix run` followed by a git commit.
update:
	nix flake lock --update-input nixpkgs --update-input darwin --update-input home-manager

# Delete all but the last few NixOS generations
freeupboot:
	sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
	sudo nixos-rebuild boot
