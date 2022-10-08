HOSTNAME := $(shell hostname -s)

all:
	if [[ "`uname`" == 'Darwin' ]]; then \
		echo macOS; \
		make macos-system; \
	else \
		echo NixOS; \
		make nixos-system; \
	fi

nixos-system:
	nixos-rebuild --use-remote-sudo switch -j auto

macos-system:
	sudo ls # cache sudo
	$$(nix build --extra-experimental-features "flakes nix-command"  .#darwinConfigurations.$(HOSTNAME).system --no-link --json | nix --extra-experimental-features "flakes nix-command" run ${WITHEXP} nixpkgs#jq -- -r '.[].outputs.out')/sw/bin/darwin-rebuild switch --flake .

# Update the primary inputs
#
# Typically run as: `make update all` followed by a git commit.
update:
	nix flake lock --update-input nixpkgs --update-input darwin --update-input home-manager

# Delete all but the last few NixOS generations
freeupboot:
	sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
	sudo nixos-rebuild boot
