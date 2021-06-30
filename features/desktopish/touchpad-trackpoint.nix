{ config, pkgs, ... }:

{
  # NOTE: libinput changes require a reboot
  services.xserver.libinput = {
    enable = true;

    # macOS like scrolling
    mouse.naturalScrolling = true;
    touchpad.naturalScrolling = true;

    # Tap to click
    touchpad.tapping = true;
  };

  hardware.trackpoint = {
    enable = true;
    sensitivity = 240;
    speed = 250;
    device = "TPPS/2 Elan TrackPoint"; # Check with `xinput`
  };
}
