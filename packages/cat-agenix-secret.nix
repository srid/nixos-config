{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "cat-agenix-secret";
  runtimeInputs = [ pkgs.ragenix ];
  meta.description = "Decrypt agenix secrets from nixos-config repo and output only the secret content";
  text = ''
    if [ $# -ne 1 ]; then
      echo "Usage: cat-agenix-secret <secret-file.age>"
      echo "Example: cat-agenix-secret hackage-password.age"
      exit 1
    fi
    
    secret_file="$1"
    
    cd "${./..}"/secrets
    # Use ragenix with EDITOR=cat to decrypt the secret (ragenix doesn't have -d option)
    set -x
    env EDITOR=cat ragenix -e "$secret_file" -i ~/.ssh/id_ed25519
  '';
}
