{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  nixos-unified.sshTarget = "srid@gossamer";

  imports = [
    self.nixosModules.default
    ./configuration.nix
    ./apple-studio-display.nix
    ./audio.nix
    ./camera.nix
    ./chrome
    ./crash-capture.nix
    ./dell-xps-16.nix
    ./geforce-now.nix
    ./desktop
    ./tailscale.nix
    (self + /modules/nixos/linux/devbox.nix)
    (self + /modules/nixos/linux/gc.nix)
    (self + /modules/nixos/linux/gtk3-xdg-output-uaf.nix)
  ];

  home-manager.sharedModules = [
    "${homeMod}/gui/1password.nix"
    "${homeMod}/cli/ssh-agent-forward.nix"
    "${homeMod}/cli/atuin.nix"
    # odu CI lane list (~/.config/odu/hosts.json); the kolu-ci-* lanes need
    # pu's ssh aliases (~/.pu-state), ci@croissant works over the tailnet.
    "${homeMod}/cli/odu.nix"
    "${homeMod}/work/juspay.nix"
    "${homeMod}/work/litellm.nix"
  ];

  # Kolu now runs on pureintent (see configurations/nixos/pureintent/kolu.nix).

  zramSwap.enable = true;
}
