{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.anywhen.nixosModules.default
  ];

  services.anywhen = {
    enable = true;
    package = inputs.anywhen.packages.${pkgs.stdenv.hostPlatform.system}.default;
    port = 6111;
  };
}
