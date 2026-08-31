# Kill whatever is listening on the given port(s).
# https://x.com/sridca/status/1861875950897578113
{ writeShellApplication, lsof, ... }:

writeShellApplication {
  name = "fuckport";
  meta.description = "Kill the process(es) listening on the given port(s)";
  runtimeInputs = [ lsof ];
  text = ''
    for port in "$@"; do
      # -t prints bare PIDs; no JSON round-trip needed. lsof exits non-zero
      # when nothing is listening, which is not an error for us.
      for pid in $(lsof -t -i ":$port" || true); do
        echo "Killing $pid ($(ps -p "$pid" -o comm= || echo '?')) on port $port"
        kill -KILL "$pid"
      done
    done
  '';
}
