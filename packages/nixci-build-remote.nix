{ writeShellApplication, curl, jq, nix, nixci, ... }:

writeShellApplication {
  name = "nixci-build-remote";
  runtimeInputs = [ curl jq nix nixci ];
  meta.description = ''
    `nixci build`, but build remotely over SSH.
  '';
  # TODO: This should handle --override-inputs
  # TODO: This should also `nix copy` nixci itself.
  text = ''
    FLAKE=$(nix flake metadata --json | jq -r .path)
    set -x
    nix copy --to "ssh://$1" "$FLAKE"
    # shellcheck disable=SC2029
    ssh "$1" nixci build "$FLAKE"
  '';
}
