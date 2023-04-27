{ config, pkgs, ... }:

let
  fixTrackpointAccelCli =
    "${pkgs.xorg.xinput}/bin/xinput --set-prop 'TPPS/2 Elan TrackPoint' 'libinput Accel Speed' 0.7";
in
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
    device = "TPPS/2 Elan TrackPoint"; # Check with `xinput`
    # FIXME: This doesn't have any effect. Whereas `xinput set-prop` (on CLI) does. See fixTrackpointAccelCli
    #sensitivity = 240;
    #speed = 250;
  };

  # Automating the aforementioned `xinput set-prop` ...
  services.xserver.displayManager.sessionCommands = ''
    ${fixTrackpointAccelCli}
  '';

  environment.systemPackages = with pkgs; [
    libinput # libinput CLI
    (pkgs.writeScriptBin "fix-trackpoint-accel"
      '' 
      #!${pkgs.runtimeShell}
      ${fixTrackpointAccelCli}
      '')
  ];
}
