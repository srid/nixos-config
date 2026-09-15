# olai home-manager config for the myolai container (its only user).
{ flake, config, ... }:

let
  inherit (flake) inputs;
  self = flake.inputs.self;
in
{
  imports = [
    inputs.olai.homeManagerModules.default
  ];

  services.olai = {
    enable = true;
    # Local outlines dir (dropbox is disabled for now; when it returns,
    # its real sync dir is ~/.dropbox-hm/Dropbox/<folder>).
    dataDir = "${config.home.homeDirectory}/Vault";
    # Loopback-only; published on the tailnet by `tailscale serve`
    # (incus.servePort in ./default.nix).
    host = "127.0.0.1";
    # Free of common tool ports.
    port = 7733;
    # commit = "auto";
    # push = "auto";
    # extraPlugins = [ "claude" "codex" "chat" "kolu" "odu" ];

    # The mail row's two doors (juspay/olai#607). The client_secret JSON is
    # decrypted by agenix as root and the values are read out of it during
    # system activation — ./default.nix writes this file, so that it exists
    # before any unit that names it as an EnvironmentFile can be started.
    environmentFile = "${config.home.homeDirectory}/.config/agenix/olai-mail.env";
  };

  # The file above is rewritten by system activation, and systemd only reads an
  # EnvironmentFile when it starts a unit — so a secret that changes would
  # otherwise stay invisible to a serve that never restarted. Keyed on the
  # encrypted file's bytes, so a rekey or a new client restarts the serve and
  # nothing else does.
  systemd.user.services.olai.Unit.X-Restart-Triggers = [
    (builtins.hashFile "sha256" (self + /secrets/olai-mail-oauth-client.json.age))
  ];
}
