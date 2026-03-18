{ flake, pkgs, ... }:
{
  imports = [
    flake.inputs.nix-agent-wire.homeModules.claude-code
  ];

  home.packages = with pkgs; [
    tree
  ];

  programs.claude-code = {
    enable = true;

    package = flake.inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.claude;

    autoWire.dirs = [
      flake.inputs.skills.outPath
      (flake.self.outPath + "/AI")
    ];
  };
}
