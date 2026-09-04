{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  nixos-unified.sshTarget = "srid@naiveintent";

  imports = [
    self.nixosModules.default
    ./configuration.nix
    (self + /modules/nixos/linux/my-workstation.nix)
    # pu / xyne-boxes + juspay-run (needs jumphost SOCKS5 from juspay.nix)
    (self + /modules/nixos/linux/devbox.nix)
    (self + /modules/nixos/linux/gc.nix)
    (self + /modules/nixos/linux/incus/host.nix)
    (self + /modules/nixos/linux/llm-debugging.nix)
    (self + /modules/nixos/linux/kill-audit.nix)
  ];

  home-manager.sharedModules = [
    "${homeMod}/gui/1password.nix"
    # Juspay pi (same as nix run github:juspay/AI#pi-juspay-oneclick)
    "${homeMod}/work/pi.nix"
    # myolai still serves the Vault outlines; this is the olai repo's own docs.
    inputs.olai.homeManagerModules.default
    ({ config, ... }: {
      services.olai = {
        enable = true;
        dataDir = "${config.home.homeDirectory}/code/oss.olai";
        push = "auto";
        plugins = [ "claude" "codex" "chat" "kolu" "odu" ];
      };
    })
  ];

  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 64 * 1024; # 64GB in megabytes
  }];

  networking.firewall.allowedTCPPorts = [ 7692 ];

  # HACK: system package so kolu MCP works on remote hosts (PATH / nix-ld), not the
  # full services.kolu user service (see modules/home/services/kolu.nix on pureintent).
  environment.systemPackages = [
    inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
