# Atuin sync server (pureintent). Clients use modules/home/cli/atuin.nix.
#
# Unique port so we don't fight kolu / tailscale HTTPS on :443.
# tailscale0 is trusted — no openFirewall.
{
  services.atuin = {
    enable = true;
    host = "0.0.0.0";
    port = 18888;
    openRegistration = true;
    openFirewall = false;
    database.createLocally = true;
  };

  services.postgresql.enable = true;
}
