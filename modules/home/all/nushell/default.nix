{ config, ... }:
{

  programs.nushell = {
    enable = true;
    envFile.source = ./env.nu;
    configFile.source = ./config.nu;
    inherit (config.home) shellAliases; # Our shell aliases are pretty simple
  };
}
