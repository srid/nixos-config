# Kill whatever is listening on the given port(s).
# https://x.com/sridca/status/1861875950897578113
{ writeShellApplication, lsof, ... }:

writeShellApplication {
  name = "fuckport";
  meta.description = "Kill the process(es) listening on the given port(s)";
  runtimeInputs = [ lsof ];
  text = ''
    for port in "$@"; do
      pid=""
      # -F pc emits one "p<pid>" line and one "c<command>" line per process,
      # so we get the name without shelling out to ps. lsof exits non-zero
      # when nothing is listening, which is not an error for us.
      while read -r line; do
        case "$line" in
          p*) pid="''${line#p}" ;;
          c*)
            [ -n "$pid" ] || continue
            echo "Killing $pid (''${line#c}) on port $port"
            kill -KILL "$pid"
            pid=""
            ;;
        esac
      done < <(lsof -F pc -i ":$port" || true)
    done
  '';
}
