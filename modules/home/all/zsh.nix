{ pkgs, lib, ... }:

{
  home.sessionPath = lib.mkIf pkgs.stdenv.isDarwin [
    "/etc/profiles/per-user/$USER/bin"
    "/nix/var/nix/profiles/system/sw/bin"
    "/usr/local/bin"
  ];
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    plugins = [
      # Fuck buggy software
      # https://github.com/jeffreytse/zsh-vi-mode/issues/317
      /* {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      } */
    ];
  };
}
