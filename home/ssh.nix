{ config, pkgs, ... }:
let
  inherit (pkgs) stdenv;
  _1passwordAgentSock =
    if stdenv.isDarwin then
      "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "${config.home.homeDirectory}/.1password/agent.sock";
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*".extraOptions = {
        identityAgent = _1passwordAgentSock;
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
        identityFile = "${config.home.homeDirectory}/.ssh/juspay.pub";
      };
    };
  };
}

