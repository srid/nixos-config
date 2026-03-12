{ flake, pkgs, ... }:
{
  imports = [ flake.inputs.oc.homeModules.default ];
  programs.opencode.package = flake.inputs.oc.packages.${pkgs.stdenv.hostPlatform.system}.default;
}
