{ flake, pkgs, lib, ... }:

# Platform-independent terminal setup
{
  home.packages = with pkgs; [
    # Unixy tools
    ripgrep
    fd

    # Useful for Nix development
    nix-output-monitor
    devour-flake
    nixci
    nil
    nixd

    nixpkgs-fmt
    shfmt
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
