{ config, ... }:
{

  programs.nushell = {
    enable = true;
    envFile.source = ./nushell/env.nu;
    configFile.source = ./nushell/config.nu;
    inherit (config.home) shellAliases; # Our shell aliases are pretty simple
  };
}
