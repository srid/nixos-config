let
  keys =
    (import ../users/config.nix).users.srid.sshKeys
    ++ [
      (import ../systems/hetzner/ax101.info.nix).hostKeyPub
    ];
in
# How I rekey on macOS:
  # agenix  -r -i =(op read 'op://Personal/id_rsa/private key')
{
  "cache-priv-key.age".publicKeys = keys;
}
