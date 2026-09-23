{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
  agents = inputs.agent-distro.lib.mkLaunchers {
    inherit pkgs;
    profile = inputs.agent-distro.profiles.vanilla;
  };
in
{
  nixos-unified.sshTarget = "srid@gossamer";

  imports = [
    self.nixosModules.default
    ./configuration.nix
    ./apple-studio-display.nix
    ./camera.nix
    ./dell-xps-16.nix
    ./input.nix
    ./tailscale.nix
    (self + /modules/nixos/linux/devbox.nix)
    (self + /modules/nixos/linux/gc.nix)
  ];

  home-manager.sharedModules = [
    "${homeMod}/gui/1password.nix"
    "${homeMod}/services/kolu.nix"
    "${homeMod}/work/juspay.nix"
    {
      # Include loopback: the local hostname resolves to 127.0.0.2.
      # Remote access is allowed only via tailscale0 in tailscale.nix.
      services.kolu.host = "0.0.0.0";
    }
  ];

  # Start Kolu's user service at boot, even before a desktop login.
  users.users.${flake.config.me.username}.linger = true;

  environment.systemPackages = [
    inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.default
    # Vanilla launchers use personal logins, without Juspay gateway credentials.
    agents.codex
    agents.claude
  ];

  zramSwap.enable = true;
}
