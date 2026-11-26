{ flake, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "pce";
  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  # Headless box: prefer compressed RAM over disk swap.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
  swapDevices = lib.mkForce [ ];

  users.users.${flake.config.me.username}.description = flake.config.me.fullname;

  # Generating the options manual evaluates every option's doc string; the
  # options are searched online instead.
  documentation.nixos.enable = false;
}
