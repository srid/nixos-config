{ pkgs, lib, ... }:

{
  # Key packages required on nixos and macos
  home.packages = with pkgs; [
    # Unixy tools
    ripgrep
    fd

    # Useful for Nix development
    nix-output-monitor
    devour-flake
    nil
    nixpkgs-fmt
  ];

  home.shellAliases = {
    e = "nvim";
    g = "git";
    lg = "lazygit";
    l = lib.getExe pkgs.exa;
  };

  programs = {
    bat.enable = true;
    autojump.enable = false;
    zoxide.enable = true;
    fzf.enable = true;
    jq.enable = true;
    nix-index.enable = true;
    htop.enable = true;
  };
}
