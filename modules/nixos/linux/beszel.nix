# Beszel monitoring - local-only setup (hub + agent on same machine)
#
# Secret file (beszel-agent-key.age) should contain:
#   KEY=ssh-ed25519 AAAA...
# Get the KEY from beszel hub web UI (http://localhost:8090) when adding a system.
{ flake, config, ... }:

let
  inherit (flake.inputs) self;
in
{
  age.secrets."beszel-agent-key.age".file = self + /secrets/beszel-agent-key.age;

  services.beszel = {
    hub = {
      enable = true;
      host = "0.0.0.0";
      port = 8090;
    };
    agent = {
      enable = true;
      environmentFile = config.age.secrets."beszel-agent-key.age".path;
    };
  };
}
