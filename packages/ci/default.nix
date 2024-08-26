{ writeShellApplication, omnix, zellij, ... }:

writeShellApplication {
  name = "ci";
  runtimeInputs = [ omnix zellij ];
  meta.description = ''
    Run CI locally.

    Powered by omnix, zellij and your beefy machines over SSH.
  '';
  text = ''
    PRJ=$(basename "$(pwd)")
    zellij --layout ${./layout.kdl} attach --create "$PRJ"-ci --force-run-commands
  '';
}
