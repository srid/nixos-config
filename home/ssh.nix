{ pkgs, lib, ... }:
{
  programs.ssh = {
    enable = true;

    # Note: More defined in juspay.nix
    matchBlocks = {
      immediacy = {
        hostname = "65.109.84.215";
        forwardAgent = true;
      };
    };
  };
}

