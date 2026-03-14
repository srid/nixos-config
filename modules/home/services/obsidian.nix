{ flake, pkgs, config, ... }:

let
  inherit (flake) inputs;
  myVault = "${config.home.homeDirectory}/Dropbox/Vault";
in
{
  home.sessionPath = [
    "/Applications/Obsidian.app/Contents/MacOS"
  ];

  imports = [
    inputs.emanote.homeManagerModule
    inputs.imako.homeManagerModules.imako
  ];

  services.emanote = {
    enable = true;
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
