{ pkgs, ... }:

# Platform-independent terminal setup
{
  home.packages = with pkgs; [
    # Unixy tools
    ripgrep
    fd
    sd
    moreutils # ts, etc.
    # Broken, https://github.com/NixOS/nixpkgs/issues/299680
    # ncdu

    # Useful for Nix development
    om-ci-build-remote
    ci
    touchpr
    omnix
    nixpkgs-fmt
    just

    # Publishing
    asciinema
    twitter-convert

    # Dev
    gh
    fuckport
    sshuttle-via
    entr

    # Fonts
    cascadia-code

    # Txns
    hledger
    hledger-web

    gnupg
  ];

  fonts.fontconfig.enable = true;

  home.shellAliases = {
    e = "nvim";
    ee = "nvim $(fzf)";
    g = "git";
    lg = "lazygit";
    l = "ls";
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
    wezterm.enable = true;
  };
}
