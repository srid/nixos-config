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

    package = pkgs.claude-code;

    autoWire.dirs = [
      (flake.self.outPath + "/AI")
    ];
  };
}
