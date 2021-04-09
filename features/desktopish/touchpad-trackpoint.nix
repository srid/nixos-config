{ config, pkgs, ... }:

{
   services.xserver.libinput = {
      enable = true;
      # macOS like behaviour
      touchpad.naturalScrolling = true;
      # Tap to click
      touchpad.tapping = true;
    };
}
