{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.mkShell {
  buildInputs = [
    pkgs.nixpkgs-fmt
    # To enable webhint to analyze source files
    pkgs.nodejs
  ];
}
