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
    ./gnome-keyring.nix
    ./guiapps.nix
    ./polybar.nix
    ./hotplug.nix

    # WMish things
    ./xmonad
    #./taffybar # Disabled, because it rarely works (and memory hungry)
    # ./xmobar # shit UX
  ];

  environment.systemPackages = with pkgs; [
    acpi
    mpv
    youtube-dl
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
