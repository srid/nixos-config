HOSTNAME := $(shell hostname -s)

all:
	if [[ "`uname`" == 'Darwin' ]]; then \
		echo macOS; \
	  make macos; \
	else \
		echo NixOS; \
	  make  nixos; \
	fi

nixos:
	sudo nixos-rebuild switch -j auto 

macos:
	sudo ls # cache sudo
	# The `TERM` needs to be set to workaround kitty issue: `tput: unknown terminal "xterm-kitty"`
	TERM=xterm $$(nix build --extra-experimental-features "flakes nix-command"  .#darwinConfigurations.$(HOSTNAME).system --no-link --json | nix --extra-experimental-features "flakes nix-command" run ${WITHEXP} nixpkgs#jq -- -r '.[].outputs.out')/sw/bin/darwin-rebuild switch --flake .

freeupboot:
	# Delete all but the last few generations
	sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
	sudo nixos-rebuild boot
