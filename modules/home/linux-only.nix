{
  imports = [
    ./all/bash.nix
    ./all/zsh.nix
    ./all/vscode-server.nix
    ./all/nushell
    ./all/ghostty.nix # Install it anyway for TERM to work on VMs
  ];
}
