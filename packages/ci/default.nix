{ writeShellApplication, om-ci-build-remote, zellij, ... }:

writeShellApplication {
  name = "ci";
  runtimeInputs = [ om-ci-build-remote zellij ];
  meta.description = ''
    Run CI locally. 

    Powered by omnix, zellij and your beefy machines over SSH.
  '';
  text = ''
    PRJ=$(basename "$(pwd)")
    zellij --layout ${./layout.kdl} attach --create "$PRJ"-ci --force-run-commands
  '';
}
