# Platform-independent terminal setup
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    inputs.try.homeManagerModules.default
  ];
  home.packages = with pkgs; [
    # Unixy tools
    neovim
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

    eternal-terminal

    uv # For running Python stuff quickly.

    # AI
    gemini-cli
    google-cloud-sdk

    # Publishing
    asciinema
    ispell
    pandoc

    # Dev
    fuckport
    sshuttle-via
    entr
    hackage-publish

    # Fonts
    cascadia-code
    monaspace

    # Txns
    hledger
    # hledger-web

    gnupg
    ffmpeg
  ];

  fonts.fontconfig.enable = true;

  home.shellAliases = {
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
    bat.enable = true;
    autojump.enable = false;
    zoxide.enable = true;
    fzf = {
      enable = true;
      defaultCommand = "fd --type f";
      enableBashIntegration = true;
    };
    jq.enable = true;
    btop.enable = true;
    try = {
      enable = true;
      path = "~/tries";
    };
  };
}
