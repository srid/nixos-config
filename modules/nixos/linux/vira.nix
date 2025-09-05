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
    hostname = "0.0.0.0";
    port = 5001;
    https = true;
    stateDir = "/var/lib/vira";
    openFirewall = true;
    package = inputs.vira.packages.${pkgs.system}.default;
  };

}
