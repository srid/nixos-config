{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.vira.homeManagerModules.vira
  ];

  services.vira = {
    enable = true;
    hostname = "0.0.0.0";
    port = 5001;
    https = true;
    package = inputs.vira.packages.${pkgs.system}.default;

    initialState = {
      repositories = {
        nixos-config = "https://github.com/srid/nixos-config.git";
        haskell-flake = "https://github.com/srid/haskell-flake.git";
        vira = "https://github.com/juspay/vira.git";
      };
    };
  };
}
