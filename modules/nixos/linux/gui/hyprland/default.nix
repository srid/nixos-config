{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
in
{
  programs.hyprland = {
    enable = true;
    # set the flake package
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  security.pam.services.hyprlock = { };

  home-manager.sharedModules = [{
    imports = [
      ./fix-cursor.nix
      ./waybar.nix
      ./settings.nix
    ];
    wayland.windowManager.hyprland = {
      enable = true;
    };
    services.dunst.enable = true;
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.hyprlock.enable = true;
    programs.rofi = {
      enable = true;
      terminal = lib.getExe pkgs.rio;
      plugins = [ pkgs.rofi-emoji ];
    };
  }];

  environment.systemPackages = with pkgs; [
    kitty
    grimblast

    acpi
    acpilight
    pavucontrol

    # TODO: https://github.com/nix-community/home-manager/pull/5489
    hyprshade
    hyprshot
    hyprpaper
    playerctl

    # TODO: https://github.com/nix-community/home-manager/issues/5899
    hyprlock

    wl-clipboard
  ];
}
