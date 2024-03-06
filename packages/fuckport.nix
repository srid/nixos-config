{ writeShellApplication, jc, jq, ... }:

writeShellApplication {
  name = "fuckport";
  runtimeInputs = [ jc jq ];
  meta.description = ''
    Kill the process with the port open

    Used only to kill stale ghc.
  '';
  # FIXME: This doesn't work when lsof returns *multiple* processes.
  text = ''
    lsof -i :"$1"
    THEPID=$(lsof -i :"$1" | jc --lsof 2> /dev/null | jq '.[].pid')
    echo "KILL $THEPID ?"
    read -r
    kill "$THEPID"
  '';
}
