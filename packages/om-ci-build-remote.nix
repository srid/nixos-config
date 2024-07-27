{ inputs, ... }:
{ writeShellApplication, jq, nix, ... }:

writeShellApplication {
  name = "om-ci-build-remote";
  runtimeInputs = [ jq nix ];
  meta.description = ''
    `om ci build`, but build remotely over SSH.
  '';
  # TODO: This should handle --override-inputs
  text = ''
    FLAKE=$(nix flake metadata --json | jq -r .path)
    set -x
    HOST="$1"; shift
    nix copy --to "ssh://$HOST" ${inputs.omnix} "$FLAKE"
    # shellcheck disable=SC2029
    ssh "$HOST" nix run ${inputs.omnix}#default -- ci build "$FLAKE" "$@"
  '';
}
