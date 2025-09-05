{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "srid@pureintent";

  imports = [
    self.nixosModules.default
    ./configuration.nix
    ./home-media.nix
    (self + /modules/nixos/linux/eternal-terminal.nix)
    (self + /modules/nixos/shared/github-runner.nix)
  ];

  home-manager.sharedModules = [
    (self + /modules/home/all/dropbox.nix)
  ];

  services.openssh.enable = true;
  services.tailscale.enable = true;
  networking.firewall.allowedTCPPorts = [
    80
  ];

  programs.nix-ld.enable = true; # for vscode server

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
