{ pkgs, ... }:
let
  session = pkgs.writeShellApplication {
    name = "chrome-session";
    runtimeInputs = [
      pkgs.python3
      pkgs.niri
    ];
    text = ''
      exec python3 ${./session.py} ${../restart/restart.py}
    '';
  };
in
{
  systemd.user.services.chrome-session = {
    description = "Remember Chrome and PWAs between Niri sessions";
    wantedBy = [ "niri.service" ];
    partOf = [ "niri.service" ];
    after = [
      "niri.service"
      "plasma-kwallet-pam.service"
    ];
    # Keep the current snapshot watcher alive across configuration switches.
    restartIfChanged = false;
    serviceConfig = {
      ExecStart = "${session}/bin/chrome-session";
      UMask = "0077";
    };
  };
}
