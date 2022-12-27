let
  keys =
    (import ../users.nix).srid.sshKeys
    ++ [
      (import ../systems/hetzner/ax41.info.nix).hostKeyPub
    ];
in
{
  "cache-priv-key.age".publicKeys = keys;
}
