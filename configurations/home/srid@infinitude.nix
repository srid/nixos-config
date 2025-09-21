{ lib, pkgs, flake, ... }:
{
  imports = [
    flake.inputs.self.homeModules.default
    flake.inputs.self.homeModules.darwin-only
  ];

  home.username = "srid";

  home.packages = [
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.tart
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        extraOptions = {
          # Configure SSH to use 1Password agent
          IdentityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
        };
      };
      "sensuous" = {
        forwardAgent = true;
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
