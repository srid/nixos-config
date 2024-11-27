{ pkgs, lib, ... }:
{
  programs.ssh = {
    enable = true;

    # Note: More defined in juspay.nix
    matchBlocks = {
      pureintent = {
        forwardAgent = true;
      };
    };
  };

  services.ssh-agent = lib.mkIf pkgs.stdenv.isLinux { enable = true; };
}
