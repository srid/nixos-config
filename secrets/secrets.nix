let
  keys =
    (import ../users/config.nix).users.ssrid.sshKeys
    ++ [
      (import ../systems/hetzner/ax41.info.nix).hostKeyPub
    ];
in
# How I rekey on macOS:
  # agenix  -r -i =(op read 'op://Personal/id_rsa/private key')
{
  "cache-priv-key.age".publicKeys = keys;
}
