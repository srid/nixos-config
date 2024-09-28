let
  config = import ../config.nix;
  users = [ config.me.sshKey ];

  appreciate = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICra+ZidiwrHGjcGnyqPvHcZDvnGivbLMayDyecPYDh0";
  immediacy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZALEiJIrH1Kj10u+WshkQXr5NHmszza8wNLqW+2fB0";
  systems = [ appreciate immediacy ];
in
{
  "hedgedoc.env.age".publicKeys = users ++ systems;
  "github-nix-ci/srid.token.age".publicKeys = users ++ systems;
}
