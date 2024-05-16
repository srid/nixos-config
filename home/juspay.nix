# For Juspay work
{ pkgs, lib, ... }:
{
  programs.ssh = {
    matchBlocks = {
      # Juspay machines (through Tailscale)
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

      # To clone Juspay repos.
      # https://developer.1password.com/docs/ssh/agent/advanced/#match-key-with-host
      "bitbucket.org" = {
        identitiesOnly = true;
        identityFile = "~/.ssh/juspay.pub";
      };
    };
  };
}

