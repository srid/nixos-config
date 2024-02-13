{ config
, pkgs
, lib
, ...
}:
with lib;
let
  inherit (pkgs) stdenv;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*".extraOptions = mkMerge [
        (mkIf (!stdenv.isDarwin) {
          identityAgent = "${config.home.homeDirectory}/.1password/agent.sock";
        })
        (mkIf (stdenv.isDarwin) {
          identityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
        })
      ];
      actual = {
        hostname = "167.205.125.179";
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

