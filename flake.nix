{
  description = "Srid's NixOS / nix-darwin configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Principle inputs (kept minimal to speed up nix develop/run/shell)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-unified.url = "github:srid/nixos-unified";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs = {
      darwin.follows = "nix-darwin";
      home-manager.follows = "home-manager";
      nixpkgs.follows = "nixpkgs";
    };

    # Everything else is managed by npins (see ./npins/)
  };

  outputs = flakeInputs@{ self, ... }:
    let
      sources = import ./npins;
      callFlake = src: (import sources.flake-compat { inherit src; }).defaultNix;

      # Source-only npins (no flake evaluation needed)
      sourceOnly = [ "nixos-vscode-server" "skills" "git-hooks" "jumphost-nix" ];

      # Merge npins-derived inputs with real flake inputs.
      # callFlake lazily evaluates via flake-compat, so `nix develop` stays fast.
      # Modules keep using `inputs.foo` / `flake.inputs.foo` unchanged.
      inputs = flakeInputs // builtins.mapAttrs
        (name: src:
          if builtins.elem name sourceOnly
          then { outPath = src; }
          else callFlake src)
        (removeAttrs sources [ "flake-compat" ]);
    in
    flakeInputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      imports = (with builtins;
        map
          (fn: ./modules/flake-parts/${fn})
          (attrNames (readDir ./modules/flake-parts)));

      perSystem = { lib, system, ... }: {
        # Make our overlay available to the devShell
        # "Flake parts does not yet come with an endorsed module that initializes the pkgs argument.""
        # So we must do this manually; https://flake.parts/overlays#consuming-an-overlay
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = lib.attrValues self.overlays;
          config.allowUnfree = true;
        };
      };
    };
}
