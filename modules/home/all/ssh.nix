{ pkgs, lib, ... }:
{
  programs.ssh = {
    enable = true;

    addKeysToAgent = "yes";

    includes = [
      "~/.orbstack/ssh/config" # https://docs.orbstack.dev/machines/ssh
    ];

    # Note: More defined in juspay.nix
    matchBlocks = {
      "*" = {
        setEnv = {
          # https://ghostty.org/docs/help/terminfo#configure-ssh-to-fall-back-to-a-known-terminfo-entry
          TERM = "xterm-256color";
        };
      };
      pureintent = {
        forwardAgent = true;
      };
    };
  };

  services.ssh-agent = lib.mkIf pkgs.stdenv.isLinux { enable = true; };
}
