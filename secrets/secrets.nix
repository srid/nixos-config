let
  config = import ../config.nix;
  users = [
    config.me.sshKey
    # zest: unique just for decrypting secrets
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYQQXPMHYBtRcPzSkjQ3oqyje8T4UlCpbr6XjrlzzlK srid@zest"
  ];

  pureintent = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOKfR7GnwrIVemP/1kna8jboNRegIsaVL6mTi3oXwMdU";
  # myolai (incus container on naiveintent) — its own ssh host key, so agenix
  # decrypts as root inside the container and hands the plaintext to the user.
  myolai = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWElR+0agAZryLk4DfrEpfFRJgKRpFJGU+ledW7izx5 root@nixos";
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
  "vira-github-webhook-secret.age".publicKeys = users ++ systems;
  "vira-github-private-key.age".publicKeys = users ++ systems;
  "olai-spaces.env.age".publicKeys = users ++ systems ++ [ kolu-bot ];
  # The mail row's Gmail OAuth client (juspay/olai#607), stored as the
  # client_secret JSON Google hands out; myolai's olai derives
  # OLAI_MAIL_OAUTH_CLIENT / OLAI_MAIL_OAUTH_SECRET from it at decrypt time.
  "olai-mail-oauth-client.json.age".publicKeys = users ++ systems ++ [ myolai ];
}
