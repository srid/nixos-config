all:
	sudo nixos-rebuild switch && systemctl restart --user emanote
