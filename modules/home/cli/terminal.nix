# Platform-independent terminal setup
{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];
  home.packages = with pkgs; [
    # Unixy tools
    ripgrep
    fd
    wget
    moreutils # ts, etc.
    gnumake
    killall
    television
    gh
    # Broken, https://github.com/NixOS/nixpkgs/issues/299680
    # ncdu

    # Useful for Nix development
    nixpkgs-fmt
    watchexec
    fswatch

    eternal-terminal

    # Publishing
    asciinema
    ispell

    # Dev
    entr

    # Fonts
    cascadia-code
    monaspace

    # Txns
    hledger

    gnupg
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
      # Atuin owns Ctrl-R; empty command disables fzf's history widget.
      historyWidget.command = "";
    };
    jq.enable = true;
    btop.enable = true;
  };
}
