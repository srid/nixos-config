{ pkgs, lib, ... }:
{
  home.packages = lib.mkIf pkgs.stdenv.isDarwin [ pkgs._1password-cli ];
  # Using native CLI on Pop OS ^

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
