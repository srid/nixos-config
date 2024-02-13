{ pkgs, lib, ... }:
let
  inherit (pkgs) stdenv;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      # Configure 1Password agent only on macOS; whilst using agent forwarding
      # to make it available to Linux machines.
      "*".extraOptions = lib.mkIf stdenv.isDarwin {
        identityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
      };
      immediacy = {
        hostname = "65.109.35.172";
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

