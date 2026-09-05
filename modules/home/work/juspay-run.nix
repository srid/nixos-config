# `juspay-run` over the jumphost SOCKS5. Home-manager so it works on zest
# (darwin) as well as the Linux hosts that import juspay.nix.
{ config, flake, pkgs, lib, ... }:

let
  socksPort = config.programs.jumphost.socks5Proxy.port;
  inherit (import (flake.inputs.self + /modules/work/pu.nix)) proxyEnv puHost;
  # netcat-openbsd is broken on Darwin; Apple nc speaks the same -X 5 -x.
  socksNc =
    if pkgs.stdenv.hostPlatform.isDarwin then "/usr/bin/nc"
    else lib.getExe pkgs.netcat-openbsd;
  socksOrDie = name: ''
    if ! (echo >/dev/tcp/127.0.0.1/${toString socksPort}) 2>/dev/null; then
      echo "${name}: nothing on 127.0.0.1:${toString socksPort} (jumphost SOCKS)." >&2
      echo "Unlock 1Password, then restart the tunnel:" >&2
      if [ "$(uname -s)" = Darwin ]; then
        echo "  launchctl kickstart -k gui/\$(id -u)/org.nix-community.home.jumphost-socks5-proxy" >&2
      else
        echo "  systemctl --user restart jumphost-socks5-proxy" >&2
      fi
      exit 1
    fi
  '';
  conf = pkgs.writeText "proxychains.conf" ''
    strict_chain
    proxy_dns
    quiet_mode
    remote_dns_subnet 224
    # Do not proxy the SOCKS listener itself. Without this, a cgo/Go
    # client honoring ALL_PROXY=socks5://127.0.0.1:${toString socksPort}
    # has its connect(127.0.0.1, ${toString socksPort}) intercepted and
    # sent through the tunnel as idli→127.0.0.1:${toString socksPort} →
    # "connection refused".
    localnet 127.0.0.0/255.0.0.0
    localnet ::1/128
    [ProxyList]
    socks5 127.0.0.1 ${toString socksPort}
  '';
in
{
  # Inner `ssh pu@${puHost}` from xyne-boxes' ssh-proxy is spawned by
  # OpenSSH ProxyCommand and does not keep DYLD_INSERT_LIBRARIES, so
  # proxychains cannot hook it. Force that hop through the jumphost SOCKS.
  programs.ssh = {
    includes = [ "~/.pu-state/*/ssh_config" ];
    settings."Match user pu" = {
      ProxyCommand = "${socksNc} -X 5 -x 127.0.0.1:${toString socksPort} %h %p";
    };
  };

  home.packages = [
    (pkgs.writeShellScriptBin "juspay-run" ''
      ${socksOrDie "juspay-run"}
      ${proxyEnv socksPort}
      # Apple /usr/bin/ssh is SIP-protected and ignores DYLD_INSERT_LIBRARIES.
      # Nix OpenSSH is the one proxychains can actually hook.
      export PATH="${lib.getBin pkgs.openssh}/bin:$PATH"
      exec ${lib.getExe' pkgs.proxychains-ng "proxychains4"} -q -f ${conf} "$@"
    '')
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    (pkgs.writeShellScriptBin "juspay-chrome" ''
      ${socksOrDie "juspay-chrome"}
      # SOCKS4: Chrome socks5 sends hostnames to idli, whose MagicDNS
      # cannot resolve public names. SOCKS4 resolves on this machine.
      # --disable-quic: OpenSSH SOCKS has no UDP (HTTP/3 would hang).
      if [ "$#" -eq 0 ]; then
        set -- "http://${puHost}/grafana/"
      fi
      exec open -na "Google Chrome" --args \
        --proxy-server="socks4://127.0.0.1:${toString socksPort}" \
        --user-data-dir="$HOME/.chrome-juspay" \
        --disable-quic \
        "$@"
    '')
  ];
}
