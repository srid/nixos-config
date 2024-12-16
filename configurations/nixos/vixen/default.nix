{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.default
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen4
    ./configuration.nix
    (self + /modules/nixos/linux/distributed-build.nix)
    (self + /modules/nixos/linux/gui/logseq.nix)
    (self + /modules/nixos/linux/gui/hyprland)
    (self + /modules/nixos/linux/gui/gnome.nix)
    (self + /modules/nixos/linux/gui/desktopish/fonts.nix)
    (self + /modules/nixos/linux/gui/_1password.nix)
  ];

  services.openssh.enable = true;
  services.tailscale.enable = true;
  # services.fprintd.enable = true; -- bad UX
  services.syncthing = rec {
    enable = true;
    user = flake.config.me.username;
    dataDir = "/home/${user}/.syncthing";
  };

  programs.nix-ld.enable = true; # for vscode server
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    google-chrome
    vscode
    telegram-desktop
  ];

  hardware.i2c.enable = true;

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
