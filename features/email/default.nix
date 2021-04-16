{ pkgs, ... }: {
  imports = [
    ./protonmail-bridge.nix
    ./himalaya-workflow.nix
    ./rss2email.nix
  ];
}
