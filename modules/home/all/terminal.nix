# Platform-independent terminal setup
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
  ];
  home.packages = with pkgs; [
    # Unixy tools
    ripgrep
    fd
    sd
    wget
    moreutils # ts, etc.
    gnumake
    killall
    television
    # Broken, https://github.com/NixOS/nixpkgs/issues/299680
    # ncdu

    # Useful for Nix development
    ci
    touchpr
    omnix
    nixpkgs-fmt
    just

    # Publishing
    asciinema
    ispell
    pandoc

    # Dev
    gh
    fuckport
    sshuttle-via
    entr
    git-merge-and-delete

    # Fonts
    cascadia-code
    monaspace

    # Txns
    hledger
    hledger-web

    gnupg
    ffmpeg
  ];

  fonts.fontconfig.enable = true;

  home.shellAliases = {
    e = "nvim";
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
    /*
      lsd = {
      enable = true;
      enableAliases = true;
      };
    */
    bat.enable = true;
    autojump.enable = false;
    zoxide.enable = true;
    fzf.enable = true;
    jq.enable = true;
    btop.enable = true;
  };
}
