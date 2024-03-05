# Stuff I need for development (not required for CI per se)
{ flake, ... }: {
  imports = [
    flake.inputs.self.nixosModules.home-manager
    flake.inputs.self.nixosModules.my-home
    ../../nixos/nix.nix
    ../../nixos/docker.nix
  ];

  programs.nix-ld.enable = true; # For vscode-server
}
