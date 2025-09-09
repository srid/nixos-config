{
  home.stateVersion = "24.05";
  imports = [
    ./all/tmux.nix
    # ./all/neovim
    ./all/helix.nix
    ./all/starship.nix
    ./all/terminal.nix
    ./all/nix.nix
    ./all/git.nix
    ./all/direnv.nix
    # ./all/zellij.nix
    ./all/just.nix
    # ./all/juspay.nix
    ./all/gotty.nix

    ./claude-code
  ];
}
