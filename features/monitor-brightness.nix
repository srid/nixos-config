{ pkgs, ... }: {
  # ddcutils requires i2c
  boot.kernelModules = [ "i2c-dev" ];

  environment.systemPackages = with pkgs; [
    # ddcutil can manage *external* monitor's brightness
    ddcutil

    # This can control the laptop display.
    brightnessctl
  ];
}
