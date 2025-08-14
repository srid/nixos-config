{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.vira.nixosModules.vira
  ];

  services.vira = {
    enable = true;

    # Basic configuration
    hostname = "0.0.0.0";
    port = 5001;
    https = false;
    stateDirectory = "/var/lib/vira";
    package = inputs.vira.packages.${pkgs.system}.default;
  };
}
