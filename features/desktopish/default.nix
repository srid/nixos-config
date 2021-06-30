{ pkgs, ... }: {
  imports = [
    # Isolated features
    ./hidpi.nix
    ./swap-caps-ctrl.nix
    ./light-terminal.nix
    ./screencapture.nix
    ./fonts.nix
    ./touchpad-trackpoint.nix
    ./autolock.nix
    ./redshift.nix

    # WMish things
    ./xmonad
    #./sway.nix
    ./taffybar # Disabled, because it rarely works
  ];

  environment.systemPackages = with pkgs; [
    acpi
    mpv
    pulsemixer
    xorg.xmessage
  ];
}
