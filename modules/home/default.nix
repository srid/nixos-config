{
  home.stateVersion = "22.11";
  imports = [
    ./all/tmux.nix
    ./all/neovim
    ./all/ssh.nix
    ./all/starship.nix
    ./all/terminal.nix
    ./all/nix.nix
    ./all/git.nix
    ./all/direnv.nix
    ./all/zellij.nix
    ./all/just.nix
    ./all/juspay.nix

    ./all/_1password.nix
  ];
}
