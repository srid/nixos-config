{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    inputs.nix-doom-emacs-unstraightened.hmModule
  ];

  programs.doom-emacs = {
    enable = true;
    emacs = pkgs.emacs30;
    doomDir = self + /doom.d;
    experimentalFetchTree = true; # Disable if there are fetcher issues
    extraPackages = epkgs: with epkgs; [
      vterm
    ];
  };
}
