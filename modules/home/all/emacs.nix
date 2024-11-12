{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    inputs.nix-doom-emacs-unstraightened.hmModule
  ];

  # https://docs.doomemacs.org/v21.12/modules/lang/org/#/prerequisites/nixos
  home.packages = [
    pkgs.texlive.combined.scheme-medium
  ];

  programs.doom-emacs = {
    enable = true;
    emacs = pkgs.emacs30-pgtk;
    doomDir = self + /doom.d;
    experimentalFetchTree = true; # Disable if there are fetcher issues
    extraPackages = epkgs: with epkgs; [
      vterm
    ];
  };
}
