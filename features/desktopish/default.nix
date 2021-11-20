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
    ./gnome-things.nix
    ./guiapps.nix

    # WMish things
    ./xmonad
    #./sway.nix
    # ./taffybar # Disabled, because it rarely works
    # ./xmobar
  ];

  environment.systemPackages = with pkgs; [
    acpi
    mpv
    xorg.xmessage
  ];

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
  };

  # Speed up boot
  # https://discourse.nixos.org/t/boot-faster-by-disabling-udev-settle-and-nm-wait-online/6339
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

}
