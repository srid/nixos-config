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
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    # https://wiki.hyprland.org/0.41.0/Nix/Hyprland-on-Home-Manager/#fixing-problems-with-themes
    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    gtk = {
      enable = true;
      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };

      iconTheme = {
        package = pkgs.gnome.adwaita-icon-theme;
        name = "Adwaita";
      };

      font = {
        name = "Sans";
        size = 11;
      };
    };
  }];
  environment.systemPackages = with pkgs; [
    kitty
    grimblast

    acpi
    acpilight

    # TODO: https://github.com/nix-community/home-manager/pull/5489
    hyprshade
    hyprshot

    # TODO: https://github.com/nix-community/home-manager/issues/5899
    hyprlock

    # launchers
    walker
  ];
}
