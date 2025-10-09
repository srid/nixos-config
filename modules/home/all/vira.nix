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
        nixos-unified-template = "https://github.com/juspay/nixos-unified-template.git";
        nixos-unified = "https://github.com/srid/nixos-unified.git";
        haskell-flake = "https://github.com/srid/haskell-flake.git";
        rust-flake = "https://github.com/juspay/rust-flake.git";
        services-flake = "https://github.com/juspay/services-flake.git";
        process-compose-flake = "https://github.com/Platonic-Systems/process-compose-flake.git";
        mission-control = "https://github.com/Platonic-Systems/mission-control.git";
        vira = "https://github.com/juspay/vira.git";
        imako = "https://github.com/srid/imako.git";
        emanote = "https://github.com/srid/emanote.git";
        ny = "https://github.com/nammayatri/nammayatri.git";
        nix-serve-cloudflared = "https://github.com/srid/nix-serve-cloudflared.git";
        vertex = "https://github.com/juspay/vertex.git";
      };
    };
  };
}
