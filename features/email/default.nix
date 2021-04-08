{ pkgs, ... }: {
  imports = [
    ./protonmail-bridge.nix
    ./himalaya-client.nix
  ];
}
