{ writeShellApplication, sshuttle, ... }:

writeShellApplication {
  name = "sshuttle-via";
  meta.description = ''
    Proxy HTTP traffic to the specified machine while we run.
  '';
  runtimeInputs = [ sshuttle ];
  text = ''
    set -x
    sshuttle -r "$1" 0/0
  '';
}
