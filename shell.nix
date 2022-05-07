{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    treefmt
    nixpkgs-fmt
    # To enable webhint to analyze source files
    nodejs
  ];
}
