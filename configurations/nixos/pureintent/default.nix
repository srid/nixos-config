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

  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.netdata = {
    enable = true;
    package = pkgs.netdataCloud;
  };
  services.nginx = {
    enable = true;
    virtualHosts."pureintent" =
      let
        apps = {
          vira = {
            baseUrlPrefix = "vira";
            port = 5005;
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
