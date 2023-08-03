{ pkgs, lib, ... }:

# Platform-independent terminal setup
{
  home.packages = with pkgs; [
    # Unixy tools
    ripgrep
    fd
    sd

    # Useful for Nix development
    devour-flake
    nixci
    nil
    nixd
    nixpkgs-fmt

    # Publishing
    asciinema

    # Dev
    gh
    fuckport
  ];

  home.shellAliases = rec {
    e = "nvim";
    g = "git";
    lg = "lazygit";
    l = lib.getExe pkgs.exa;
    t = tree;
    tree = "${lib.getExe pkgs.exa} -T";
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
