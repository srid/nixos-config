{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  # nixos-unified.sshTarget = "srid@192.168.2.43";
  nixos-unified.sshTarget = "srid@pureintent";

  imports = [
    self.nixosModules.default
    ./configuration.nix
    (self + /webapps/host.nix)
  ];

  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.netdata = {
    enable = true;
    package = pkgs.netdataCloud;
  };
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  programs.nix-ld.enable = true; # for vscode server

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
