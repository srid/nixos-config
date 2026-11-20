# netbird in userspace "netstack" mode, as a user service: the WireGuard tunnel
# is dialled from the process, so it needs no root, no kernel interface and no
# /etc/resolv.conf rewrites, and forwarding is netstack's own TCP/UDP forward.
#
# NetBird's netstack SOCKS5 proxy is the way into the netbird network from
# another machine, so it binds the tailnet address instead of the loopback
# default (127.0.0.1:1080): a host that trusts tailscale0 in its firewall then
# exposes the proxy to the tailnet and to nothing else. Override the address
# with NB_SOCKS5_LISTENER_ADDRESS in the unit's environment.
#
# netbird-local also runs the client in the foreground for a manual look; extra
# arguments go to `netbird up` (e.g. --setup-key <key>). First start needs an
# interactive login: the unit's journal carries the
# https://login.netbird.io/activate?user_code=… URL.
{ pkgs, ... }:

let
  netbird-local = pkgs.writeShellApplication {
    name = "netbird-local";
    runtimeInputs = [ pkgs.netbird pkgs.tailscale ];
    text = ''
      # The address exists only once tailscaled has joined, which is later than
      # the user manager starts on a cold boot: the unit restarts until it does.
      addr="''${NB_SOCKS5_LISTENER_ADDRESS:-$(tailscale ip -4 | head -n1)}"
      if [ -z "$addr" ]; then
        echo "netbird-local: no tailscale IPv4 address yet" >&2
        exit 1
      fi

      mkdir -p "$HOME/.netbird"
      export NB_USE_NETSTACK_MODE=true
      export NB_STATE_DIR="$HOME/.netbird"
      export NB_ENABLE_NETSTACK_LOCAL_FORWARDING=true
      export NB_DISABLE_SSH_CONFIG=true
      export NB_SOCKS5_LISTENER_ADDRESS="$addr"

      exec netbird up --foreground-mode --log-file console "$@"
    '';
  };
in
{
  home.packages = [ netbird-local ];

  systemd.user.services.netbird-local = {
    Unit.Description = "netbird in netstack mode, SOCKS5 proxy on the tailnet address";
    Service = {
      ExecStart = "${netbird-local}/bin/netbird-local";
      Restart = "on-failure";
      # tailscaled is not up yet when the user manager first tries.
      RestartSec = 10;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
