let
  config = import ../config.nix;
  users = [ config.me.sshKey ];

  pureintent = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkY5feaNt4elPqRQimB9h3OFxtFAzp98p1H+JezBv92 root@nixos";
  infinitude-macos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICjg6aknmaXdQ/arHcTD+USFwCTsUGyJv9R1dXnejdby";
  infinitude-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhLuTee/YS04uBhg9Zri5OKfQySoeUXxVVpz6xVUtB5";
  systems = [ pureintent infinitude-macos infinitude-nixos ];
in
{
  "hedgedoc.env.age".publicKeys = users ++ systems;
  "github-nix-ci/srid.token.age".publicKeys = users ++ systems;
  "github-nix-ci/emaletter.token.age".publicKeys = users ++ systems;
  "pureintent-basic-auth.age".publicKeys = users ++ systems;
  "gmail-app-password.age".publicKeys = users ++ systems;
  "hackage-password.age".publicKeys = users ++ systems;
}
