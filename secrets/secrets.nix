let
  keys = [
    (builtins.readFile ../nixos/takemessh/id_rsa.pub)
    (builtins.readFile ../systems/hetzner/ax41.pub)
  ];
in
{
  "cache-priv-key.age".publicKeys = keys;
}
