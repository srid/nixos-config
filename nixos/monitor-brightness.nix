# TODO: GNOME support via https://extensions.gnome.org/extension/2645/brightness-control-using-ddcutil/

{ pkgs, ... }: {
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
      users = [ "srid" ];
      commands = [
        {
          command = "${pkgs.ddcutil}/bin/ddcutil";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  users.users.srid = {
    extraGroups = [ "i2c" ];
  };

}
