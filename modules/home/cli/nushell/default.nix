{ config, ... }:
{
  programs.nushell = {
    enable = true;
    envFile.source = ./env.nu;
    configFile.source = ./config.nu;
    shellAliases = config.home.shellAliases;
  };
}
