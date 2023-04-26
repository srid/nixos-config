{ pkgs, ... }:

{
  # Key packages required on nixos and macos
  home.packages = with pkgs; [
    # Unixy tools
    gnumake
    ripgrep
    htop
    nix-output-monitor
    devour-flake
    nil
    nixpkgs-fmt
  ];

  programs = {
    bat.enable = true;
    autojump.enable = false;
    zoxide.enable = true;
    fzf.enable = true;
    jq.enable = true;
    nix-index.enable = true;
  };
}
