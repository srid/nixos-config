{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  hyprlandPkgs = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.hyprland = {
    enable = true;
    # set the flake package
    package = hyprlandPkgs.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = hyprlandPkgs.xdg-desktop-portal-hyprland;
  };

  security.pam.services.hyprlock = { };

  home-manager.sharedModules = [ ./home ];

  # hint Electron apps to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
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
