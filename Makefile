OS := $(shell uname)


# TODO: Automatically detect platform.
all:
	$(error Choose a platform (eg: 'make macos'))

nixos:
	sudo nixos-rebuild switch -j auto 

macos:
	sudo ls # cache sudo
	$$(nix build --extra-experimental-features "flakes nix-command" .#darwinConfigurations.air.system --no-link --json | jq -r '.[].outputs.out')/sw/bin/darwin-rebuild switch --flake .

freeupboot:
	# Delete all but the last few generations
	sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
	sudo nixos-rebuild boot
