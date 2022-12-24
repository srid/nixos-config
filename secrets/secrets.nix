let
  keys = [
    (builtins.readFile ../nixos/takemessh/id_rsa.pub)
    (import ../systems/hetzner/ax41.info.nix).hostKeyPub
  ];
in
{
  "cache-priv-key.age".publicKeys = keys;
}
