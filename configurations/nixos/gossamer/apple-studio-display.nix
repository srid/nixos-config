{ pkgs, ... }:

{
  services.hardware.bolt.enable = true;
  environment.systemPackages = [ pkgs.asdbctl ];
  services.udev.packages = [ pkgs.asdbctl ];

  # Prefer dock speakers to the laptop's speakers (712), while leaving wired
  # headphones (1000) ahead. WirePlumber reselects when outputs come and go;
  # an explicit choice in the sound menu still overrides this preference.
  services.pipewire.wireplumber.extraConfig."51-studio-display-audio" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "~alsa_output.usb-Apple_Inc._Studio_Display_.*"; }
        ];
        actions.update-props."priority.session" = 900;
      }
    ];
  };
}
