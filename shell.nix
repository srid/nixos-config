{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.mkShell {
  buildInputs = [
    pkgs.nixpkgs-fmt
  ];
}
