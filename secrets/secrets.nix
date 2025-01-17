let
  config = import ../config.nix;
  users = [ config.me.sshKey ];

  appreciate = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICra+ZidiwrHGjcGnyqPvHcZDvnGivbLMayDyecPYDh0";
  pureintent = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkY5feaNt4elPqRQimB9h3OFxtFAzp98p1H+JezBv92 root@nixos";
  systems = [ appreciate pureintent ];
in
{
  "hedgedoc.env.age".publicKeys = users ++ systems;
  "github-nix-ci/srid.token.age".publicKeys = users ++ systems;
  "pureintent-basic-auth.age".publicKeys = users ++ systems;
}
