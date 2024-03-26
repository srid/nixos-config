{ lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    # This must be envExtra (rather than initExtra), because doom-emacs requires it
    # https://github.com/doomemacs/doomemacs/issues/687#issuecomment-409889275
    #
    # But also see: 'doom env', which is what works.
    envExtra = ''
      export PATH=/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin/:/usr/local/bin:$PATH

      # Because, adding it in .ssh/config is not enough.
      # cf. https://developer.1password.com/docs/ssh/get-started#step-4-configure-your-ssh-or-git-client
      export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
    '';
  };
}
