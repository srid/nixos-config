{ pkgs, ... }: {
  # ddcutils requires i2c
  boot.kernelModules = [ "i2c-dev" ];

  environment.systemPackages = with pkgs; [
    ddcutil
  ];
}
