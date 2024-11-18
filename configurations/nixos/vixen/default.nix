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
    (self + /modules/nixos/linux/gui/hyprland)
    (self + /modules/nixos/linux/gui/gnome.nix)
    (self + /modules/nixos/linux/gui/desktopish/fonts.nix)
    (self + /modules/nixos/linux/gui/desktopish/steam.nix)
    (self + /modules/nixos/linux/gui/_1password.nix)

    # bevel perSystem home module
    # XXX: Can't do this in `modules/home` due to upstream design
    {
      home-manager.sharedModules = [
        flake.inputs.bevel.homeManagerModules.${pkgs.system}.default
        {
          programs.bevel = {
            enable = true; # Make the CLI available
            harness = {
              bash = {
                enable = true; # Gather history from bash
                bindings = true; # Bind C-p and C-r
              };
            };
          };
        }
      ];
    }
  ];

  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.fprintd.enable = true;
  services.syncthing = { enable = true; user = "srid"; dataDir = "/home/srid/Documents"; };

  programs.nix-ld.enable = true; # for vscode server

  environment.systemPackages = with pkgs; [
    google-chrome
    vscode
    zed-editor
    telegram-desktop
  ];

  hardware.i2c.enable = true;

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
