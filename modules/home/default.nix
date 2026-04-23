{
  home.stateVersion = "24.05";
  home.sessionVariables = {
    DO_NOT_TRACK = "1";
  };
  imports = [
    ./cli/tmux.nix
    ./editors/neovim
    # ./editors/helix.nix
    ./cli/starship.nix
    ./cli/terminal.nix
    ./nix/path.nix
    ./cli/git.nix
    ./cli/direnv.nix
    # ./cli/zellij.nix
    ./cli/just.nix
    ./cli/npm.nix
    ./services/ttyd.nix
  ];
}
