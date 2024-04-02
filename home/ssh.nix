{ pkgs, lib, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      vanjaram = {
        hostname = "100.83.79.127";
        user = "srid";
        forwardAgent = true;
      };
      biryani = {
        hostname = "100.97.32.60";
        user = "admin";
        forwardAgent = true;
      };
      immediacy = {
        hostname = "65.109.84.215";
        forwardAgent = true;
      };
      # To clone Juspay repos.
      # https://developer.1password.com/docs/ssh/agent/advanced/#match-key-with-host
      "bitbucket.org" = {
        identitiesOnly = true;
        identityFile = "~/.ssh/juspay.pub";
      };
    };
  };
}

