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
  "jenkins-ssh-privkey.age".publicKeys = keys;
  "jenkins-github-app-privkey.age".publicKeys = keys;
  "srid-cachix-auth-token.age".publicKeys = keys;
  "srid-docker-pass.age".publicKeys = keys;
}
