{ flake, pkgs, ... }:
let
  inherit (flake.inputs) AI;
in
{
  imports = [
    AI.homeManagerModules.claude-code
  ];

  home.packages = with pkgs; [
    tree
  ];

  programs.claude-code = {
    enable = true;

    package = flake.inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.claude;

    autoWire.dir = AI;
  };
}
