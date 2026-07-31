# Atuin client (home-manager). Sync server: modules/nixos/linux/atuin.nix on pureintent.
#
# After deploy: `atuin register` / `atuin login` once; `atuin key` on other hosts.
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
}
