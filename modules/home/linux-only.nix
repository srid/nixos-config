{
  imports = [
    ./all/bash.nix
    ./all/zsh.nix
    ./all/vscode-server.nix
    # ./all/emacs.nix
    # ./all/obs.nix
    # ./all/zed
    # ./all/obs.nix

    # Terms
    # ./all/rio.nix
    # ./all/wezterm
    ./all/ghostty.nix # Install it anyway for TERM to work on VMs
    # ./all/kitty.nix

    # FIXME: disable this only for tartvm
    # ./all/dropbox.nix
  ];
}
