{ flake, ... }:
let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.github-nix-ci.nixosModules.default
  ];

  services.github-nix-ci = {
    age.secretsDir = ../secrets;
    personalRunners = {
      "srid/srid".num = 1;
    };
  };
}
