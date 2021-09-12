{
  description = "Home Manager configurations";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, homeManager }: {
    homeConfigurations = {
      "srid@P71" = homeManager.lib.homeManagerConfiguration {
        configuration = { pkgs, ... }: {
          programs.home-manager.enable = true;
          home.packages = [ pkgs.hello ];
        };

        system = "x86_64-linux";
        homeDirectory = "/home/srid";
        username = "srid";
        stateVersion = "21.05";
      };
    };
  };
}
