{ flake, config, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.drishti.homeManagerModules.default
  ];

  services.drishti = {
    enable = true;
    package = inputs.drishti.packages.${pkgs.stdenv.hostPlatform.system}.default;
    port = 7720;
    hosts = [ "localhost" "sincereintent" "pureintent" "vanjaram.tail12b27.ts.net" "nix-infra@rasam.tail12b27.ts.net" ];
  };
}
