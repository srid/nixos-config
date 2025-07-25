default:
    @just --list

# Activate local system configuration 
[group('main')]
system:
    nix run . $HOSTNAME

# Activate local home configuration
[group('main')]
home:
    nix run . $USER@$HOSTNAME

# Update primary flame inputs
update:
    nix run .#update

# Deploy to Beelink
[group('deploy')]
pureintent:
    nix run . pureintent

# Deploy to infinitude (mac)
[group('deploy')]
infinitude:
    nix run . infinitude

# Activate home config on stillness
[group('deploy')]
stillness:
    nix run . $USER@

# Deploy to orb nixos machine
# [group('deploy')]
# orb:
#     nix run . orb-nixos

# Deploy to tart VM
[group('deploy')]
tart:
    nix run . infinitude-nixos

# SSH to tart CM
[group('ssh')]
tart-ssh:
    ssh $(tart ip nixos-vm)

# Run all pre-commit hooks on all files
pca:
    pre-commit run --all-files

# https://discourse.nixos.org/t/why-doesnt-nix-collect-garbage-remove-old-generations-from-efi-menu/17592/4
fuckboot:
    sudo nix-collect-garbage -d
    sudo /run/current-system/bin/switch-to-configuration boot
