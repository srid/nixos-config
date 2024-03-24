# Parallels VM support
{
  hardware.parallels.enable = true;
  nixpkgs.config.allowUnfree = true; # for parallels
  services.ntp.enable = true; # Accurate time in Parallels VM?
}
