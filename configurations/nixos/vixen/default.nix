# Hetzner dedicated: AX41-NVMe
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.default
    ./configuration.nix
  ];

  services.openssh.enable = true;
  services.tailscale.enable = true;

  programs.nix-ld.enable = true; # for vscode server
}
