{
  home.stateVersion = "24.05";
  home.sessionVariables = {
    # Disabled, see
    # https://github.com/anthropics/claude-code/issues/69358#issuecomment-4755677033
    # DO_NOT_TRACK = "1";
  };

  # Home-manager generates an options manpage (`home-configuration.nix(5)`) by
  # default, which evaluates the doc string of every HM option. Options are
  # searched online, not via `man`, so skip it — measurable eval-time win.
  manual.manpages.enable = false;
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
