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

    envExtra = lib.mkIf pkgs.stdenv.isDarwin ''
      # Because, adding it in .ssh/config is not enough.
      # cf. https://developer.1password.com/docs/ssh/get-started#step-4-configure-your-ssh-or-git-client
      export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
    '';
  };
}
