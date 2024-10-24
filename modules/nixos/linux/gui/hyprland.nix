{ flake, pkgs, ... }:

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
    services.dunst.enable = true;
    programs.hyprlock.enable = true;
  }];
  environment.systemPackages = with pkgs; [
    kitty
    hyprpaper
    hyprnome
    hyprshade

    # launchers
    walker
  ];
}
