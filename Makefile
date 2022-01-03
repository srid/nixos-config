OS := $(shell uname)


all:
	echo "fuck you shell scripting"

nixos:
	sudo nixos-rebuild switch -j auto 
	# systemctl restart --user emanote

macos:
	$$(nix build --extra-experimental-features "flakes nix-command" .#darwinConfigurations.air.system --no-link --json | jq -r '.[].outputs.out')/sw/bin/darwin-rebuild switch --flake .

# Not sure why this doesn't reliably work
h0:
	nix build ".#homeConfigurations."`hostname`".activationPackage"
	./result/activate

# This requires the symlink to be setup; see README
h:
	PATH="${HOME}/.nix-profile/bin/:${PATH}" home-manager  switch
	
freeupboot:
	# Delete all but the last few generations
	sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
	sudo nixos-rebuild boot
