{ pkgs, lib, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Explicitly set default SSH configuration
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
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
