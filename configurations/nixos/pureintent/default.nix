{ flake, pkgs, lib, ... }:

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
    (self + /modules/nixos/linux/lxd.nix)
    (self + /modules/nixos/shared/github-runner.nix)
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # For flake containers to have network access!
  networking.nat = {
    enable = true;
    # cf. https://github.com/NixOS/nixpkgs/issues/72580#issuecomment-1783933476
    internalInterfaces = [ "ve-+" "ve-*" ];
    # NOTE: Change this to your network interface name, from `ifconfig` command
    externalInterface = "enp1s0";
  };

  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.nginx = {
    enable = true;
    virtualHosts."pureintent" =
      let
        apps = {
          vira-dev = {
            baseUrlPrefix = "vira-dev";
            port = 5005;
          };
          vira = {
            baseUrlPrefix = "vira";
            port = 5001;
          };
        };
      in
      {
        locations = lib.mapAttrs'
          (name: value: lib.nameValuePair "/${value.baseUrlPrefix}/" {
            proxyPass = "http://localhost:${builtins.toString value.port}/";
            proxyWebsockets = true;
          })
          apps;
      };
  };
  networking.firewall.allowedTCPPorts = [
    80
  ];

  programs.nix-ld.enable = true; # for vscode server

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
