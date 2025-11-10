{ flake, config, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.vira.homeManagerModules.vira
  ];

  home.packages = [
    config.services.vira.package # For CLI
  ];

  services.vira = {
    enable = true;
    port = 5001;
    hostname = "127.0.0.1";
    https = false; # Using tailscale services
    autoResetState = true;
    autoBuildNewBranches = true;
    package = inputs.vira.packages.${pkgs.system}.default;

    initialState = {
      repositories = {
        nixos-config = "https://github.com/srid/nixos-config.git";
        nixos-unified-template = "https://github.com/juspay/nixos-unified-template.git";
        nixos-unified = "https://github.com/srid/nixos-unified.git";
        hackage-publish = "https://github.com/srid/hackage-publish.git";
        haskell-flake = "https://github.com/srid/haskell-flake.git";
        rust-flake = "https://github.com/juspay/rust-flake.git";
        services-flake = "https://github.com/juspay/services-flake.git";
        process-compose-flake = "https://github.com/Platonic-Systems/process-compose-flake.git";
        vira = "https://github.com/juspay/vira.git";
        imako = "https://github.com/srid/imako.git";
        emanote = "https://github.com/srid/emanote.git";
        srid = "https://github.com/srid/srid.git";
        vertex = "https://github.com/juspay/vertex.git";
        landrun-nix = "https://github.com/srid/landrun-nix.git";
        # Just to test heavy weight stuff
        superposition = "https://github.com/juspay/superposition.git";
      };
    };
  };
}
