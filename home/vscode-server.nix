{ pkgs, inputs, ... }:
{
  imports = [
    "${inputs.nixos-vscode-server}/modules/vscode-server/home.nix"
  ];

  services.vscode-server.enable = true;
}
