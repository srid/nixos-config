# TODO: GNOME support via https://extensions.gnome.org/extension/2645/brightness-control-using-ddcutil/
#
# NOTE: For Apple Display, we need https://github.com/juliuszint/asdbctl

{ pkgs, flake, ... }: {
  # ddcutils requires i2c
  hardware.i2c.enable = true;

  environment.systemPackages = with pkgs;
    [
      # ddcutil can manage *external* monitor's brightness
      ddcutil

      # This can control the laptop display.
      brightnessctl
    ];

  security.sudo.extraRules = [
    {
      users = [ flake.config.me.username ];
      commands = [
        {
          command = "${pkgs.ddcutil}/bin/ddcutil";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  users.users.${flake.config.me.username} = {
    extraGroups = [ "i2c" ];
  };

}
