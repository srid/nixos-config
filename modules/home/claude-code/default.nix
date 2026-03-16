{ flake, pkgs, ... }:
{
  imports = [
    flake.inputs.nix-agent-wire.homeManagerModules.claude-code
  ];

  home.packages = with pkgs; [
    tree
  ];

  programs.claude-code = {
    enable = true;

    package = flake.inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.claude;

    autoWire.dir = flake.self.outPath + "/AI";
  };
}
