{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  # nixos-unified.sshTarget = "root@5.161.184.111";
  nixos-unified.sshTarget = "gate";

  imports = [
    ./configuration.nix
    (self + /modules/nixos/shared/primary-as-admin.nix)
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  services.tailscale.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."actualism.app" = {
      # FIXME: Don't hardcode, instead of read from pureintent's containers.nix
      locations."/".proxyPass = "http://pureintent:3000";
      enableACME = true;
      addSSL = true;
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "srid@srid.ca";
  };
  networking.firewall.allowedTCPPorts = [ 80 443 22 ];

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
