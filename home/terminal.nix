{ pkgs, lib, ... }:

# Platform-independent terminal setup
{
  home.packages = with pkgs; [
    # Unixy tools
    ripgrep
    fd
    sd
    moreutils # ts, etc.

    # Useful for Nix development
    devour-flake
    nixci
    nil
    nixpkgs-fmt

    # Publishing
    asciinema

    # Dev
    gh
    fuckport
  ];

  home.shellAliases = {
    e = "nvim";
    g = "git";
    lg = "lazygit";
    beep = "say 'beep'";
  };

  programs = {
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    lsd = {
      enable = true;
      enableAliases = true;
    };
    bat.enable = true;
    autojump.enable = false;
    zoxide.enable = true;
    fzf.enable = true;
    jq.enable = true;
    htop.enable = true;
    rio.enable = true;
  };
}
