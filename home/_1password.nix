{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    _1password
    gh
  ];

  programs.zsh.envExtra = ''
    # For 1Password CLI. This requires `pkgs.gh` to be installed.
    # source $HOME/.config/op/plugins.sh
  '';

  programs.ssh = {
    enable = true;
    matchBlocks = {
      # Configure 1Password agent only on macOS; whilst using agent forwarding
      # to make it available to Linux machines.
      "*".extraOptions = lib.mkIf pkgs.stdenv.isDarwin {
        identityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
      };
    };
  };
}
