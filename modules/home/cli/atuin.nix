# Atuin client (home-manager). Sync server: modules/nixos/linux/atuin.nix on pureintent.
#
# After deploy: `atuin register` / `atuin login` once; `atuin key` on other hosts.
{ lib, ... }:
{
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "http://pureintent.rooster-blues.ts.net:18888";
      history_filter = [
        "^export .*(KEY|TOKEN|SECRET|PASSWORD)="
        "^.*API_KEY=.*"
      ];
    };
  };

  # Bash's own history no longer survives a shell (modules/home/cli/bash.nix), so
  # Ctrl-P must ask Atuin too. Up already opens Atuin's up-search; Ctrl-P is
  # readline's previous-history and would otherwise walk an empty session list.
  # vi-command keeps its own movement keys, as Atuin does for Ctrl-R.
  programs.bash.initExtra = lib.mkAfter ''
    atuin-bind -m emacs     '\C-p' atuin-up-search-emacs
    atuin-bind -m vi-insert '\C-p' atuin-up-search-viins
  '';

  # Same reasoning for zsh on macOS, where Atuin installs atuin-up-search on Up.
  programs.zsh.initContent = lib.mkAfter ''
    bindkey -M emacs '^P' atuin-up-search
    bindkey -M viins '^P' atuin-up-search-viins
  '';
}
