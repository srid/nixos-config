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
    ./all/nushell
    ./all/ghostty.nix # Install it anyway for TERM to work on VMs
    # ./all/kitty.nix
  ];
}
