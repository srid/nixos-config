{ flake, pkgs, config, ... }:

let
  inherit (flake) inputs;
  myVault = "${config.home.homeDirectory}/Dropbox/Vault";
in
{
  imports = [
    inputs.emanote.homeManagerModule
    inputs.imako.homeManagerModules.imako
  ];

  services.emanote = {
    enable = false;
    notes = [ myVault ];
    port = 7001;
    package = inputs.emanote.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  services.imako = {
    enable = true;
    package = inputs.imako.packages.${pkgs.stdenv.hostPlatform.system}.default;
    vaultDir = myVault;
    port = 7002;
    host = "0.0.0.0";
  };
}
