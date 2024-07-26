{ inputs, ... }:
{ writeShellApplication, jq, nix, ... }:

writeShellApplication {
  name = "om-ci-build-remote";
  runtimeInputs = [ jq nix ];
  meta.description = ''
    `nixci build`, but build remotely over SSH.
  '';
  # TODO: This should handle --override-inputs
  text = ''
    FLAKE=$(nix flake metadata --json | jq -r .path)
    set -x
    nix copy --to "ssh://$1" "$FLAKE"
    nix copy --to "ssh://$1" ${inputs.omnix}
    # shellcheck disable=SC2029
    ssh "$1" nix run ${inputs.omnix}#default ci build "$FLAKE"
  '';
}
