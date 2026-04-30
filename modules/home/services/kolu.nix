{ flake, config, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.kolu.homeManagerModules.default
  ];

  services.kolu = {
    enable = true;
    package = inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.default;
    port = 7692;
  };
}
