{ lib, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        extraOptions = {
          # Configure SSH to use 1Password agent
          IdentityAgent =
            if pkgs.stdenv.isDarwin
            then "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock"
            else "~/.1password/agent.sock";
        };
      };
      "pureintent" = {
        forwardAgent = true;
      };
      "sincereintent" = {
        forwardAgent = true;
      };
    };
  };
}
