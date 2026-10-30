let
  config = import ../config.nix;
  users = [
    config.me.sshKey
    # zest: unique just for decrypting secrets
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYQQXPMHYBtRcPzSkjQ3oqyje8T4UlCpbr6XjrlzzlK srid@zest"
  ];

  pureintent = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOKfR7GnwrIVemP/1kna8jboNRegIsaVL6mTi3oXwMdU";
  naiveintent = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPBdMc145nH1JYFDF6q6gsSN/pqr3HCf1/BTgmOz6lod root@naiveintent";
  # OVH dedicated; host key pre-seeded at install (see configurations/nixos/croissant/README.md)
  croissant = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyvR3teMNb8tdNLXkLLfcPT6ntZjW9QRFQ1U+spbbkN root@croissant";
  # home-manager identity (~/.ssh/agenix), not the host key
  kolu-bot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgJNPiUb9JjusNGqChTsenpvVbgjcv5GTDLEu4OJnIV toor@kolu-bot";
  systems = [
    pureintent
  ];
in
{
  "hedgedoc.env.age".publicKeys = users ++ systems;
  "github-nix-ci/srid.token.age".publicKeys = users ++ systems;
  "github-nix-ci/emaletter.token.age".publicKeys = users ++ systems;
  "pureintent-basic-auth.age".publicKeys = users ++ systems;
  "gmail-app-password.age".publicKeys = users ++ systems;
  "hackage-password.age".publicKeys = users ++ systems;
  "juspay-anthropic-api-key.age".publicKeys = users ++ systems ++ [ kolu-bot ];
  "oauth2-proxy.env.age".publicKeys = users ++ systems ++ [ kolu-bot ];
  "beszel-agent-key.age".publicKeys = users ++ systems;
  # Wi-Fi PSK consumed by NetworkManager's declarative profile on pureintent.
  "wifi-psk.env.age".publicKeys = users ++ systems;
  "vira-github-webhook-secret.age".publicKeys = users ++ systems;
  "vira-github-private-key.age".publicKeys = users ++ systems;
  "olai-spaces.env.age".publicKeys = users ++ systems ++ [ kolu-bot ];
  "tailscale-operator-oauth.yaml.age".publicKeys = users ++ [ naiveintent ];
  # Bootstrap read-only access to the Kubernetes vault in 1Password.
  "onepassword-token.json.age".publicKeys = users ++ [ naiveintent ];
  # Reusable, pre-authorized Tailscale auth key (1Password: "tailscale join");
  # lets a freshly installed host join the tailnet on first boot.
  "tailscale-authkey.age".publicKeys = users ++ [ croissant ];
}
