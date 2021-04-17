{ pkgs, ... }: {
  imports = [
    ./protonmail-bridge.nix
    ./himalaya-workflow.nix
  ];
}
