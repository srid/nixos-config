# Stuff I need for development (not required for CI per se)
{ flake, ... }: {
  imports = [
    flake.inputs.self.nixosModules.home-manager
    flake.inputs.self.nixosModules.my-home
    ../../nixos/nix.nix
  ];

  virtualisation.docker.enable = true;
}
