{ writeShellApplication, niri, jq }:
writeShellApplication {
  name = "niri-focus-or-launch";
  runtimeInputs = [ niri jq ];
  text = ''
    if [ "$#" -lt 2 ]; then
      echo "usage: niri-focus-or-launch <app-id> <command> [args...]" >&2
      exit 2
    fi
    app_id=$1
    shift
    windows=$(niri msg --json windows)
    window_id=$(jq -r --arg app "$app_id" \
      '[.[] | select(.app_id == $app)] | sort_by(.is_focused) | last | .id // empty' <<< "$windows")
    if [ -n "$window_id" ]; then
      niri msg action focus-window --id "$window_id"
      niri msg action close-overview
    else
      exec "$@"
    fi
  '';
}
