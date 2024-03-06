{ pkgs, ... }:

# Platform-independent terminal setup
{
  home.packages = with pkgs; [
    # Unixy tools
    ripgrep
    fd
    sd
    ncdu
    moreutils # ts, etc.

    # Useful for Nix development
    nixci
    nix-health
    nil
    nixpkgs-fmt
    just

    # Publishing
    asciinema
    twitter-convert

    # Dev
    gh
    fuckport
  ];

  home.shellAliases = {
    e = "nvim";
    ee = "nvim $(fzf)";
    g = "git";
    lg = "lazygit";
    beep = "say 'beep'";
  };

  programs = {
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    nix-index-database.comma.enable = true;
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
