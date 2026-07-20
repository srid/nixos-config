{ writeShellApplication, openssh, ... }:

writeShellApplication {
  name = "portfwd";
  meta.description = ''
    Forward a local port to the same port on a remote host over SSH.
    Usage: portfwd <port> [host]   (host defaults to naiveintent)
    e.g. `portfwd 7721` or `portfwd 7721 pureintent`
  '';
  runtimeInputs = [ openssh ];
  text = ''
    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
      echo "usage: portfwd <port> [host]" >&2
      exit 1
    fi
    port="$1"
    host="''${2:-naiveintent}"
    ssh -L "$port:localhost:$port" "$host"
  '';
}
