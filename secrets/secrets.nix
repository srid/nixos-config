let
  config = import ../config.nix;
  users = [
    config.me.sshKey
    # zest: unique just for decrypting secrets
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYQQXPMHYBtRcPzSkjQ3oqyje8T4UlCpbr6XjrlzzlK srid@zest"
  ];

  pureintent = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkY5feaNt4elPqRQimB9h3OFxtFAzp98p1H+JezBv92 root@nixos";
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
  "juspay-anthropic-api-key.age".publicKeys = users ++ systems;
}
