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
    host = "100.122.32.106"; # Tailscale IP of pureintent
    port = 7681;
  };
}
