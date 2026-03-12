{ writeShellApplication, zellij, ... }:

writeShellApplication {
  name = "zellij-one";
  meta.description = ''
    Create or attach to a singular zellij session named 'one'.
  '';
  runtimeInputs = [ zellij ];
  text = ''
    zellij attach --create one
  '';
}
