{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    logseq
  ];

  # For logseq
  nixpkgs.config.permittedInsecurePackages = [
    "electron-27.3.11"
  ];
}
