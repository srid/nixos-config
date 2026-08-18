# `juspay-run` over the jumphost SOCKS5. Home-manager so it works on zest
# (darwin) as well as the Linux hosts that import juspay.nix.
{ config, pkgs, lib, ... }:

let
  socksPort = config.programs.jumphost.socks5Proxy.port;
  # Hostname `pu` is not reachable through the jumphost SOCKS. Same pin as
  # modules/nixos/linux/devbox.nix; xyne-boxes defaults PU_HOST to `pu`.
  # https://github.com/juspay/xyne-boxes/pull/14#issuecomment-4918563982
  puHost = "10.10.68.56";
  # netcat-openbsd is broken on Darwin; Apple nc speaks the same -X 5 -x.
  socksNc =
    if pkgs.stdenv.hostPlatform.isDarwin then "/usr/bin/nc"
    else lib.getExe pkgs.netcat-openbsd;
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
      if ! (echo >/dev/tcp/127.0.0.1/${toString socksPort}) 2>/dev/null; then
        echo "juspay-run: nothing on 127.0.0.1:${toString socksPort} (jumphost SOCKS)." >&2
        echo "Unlock 1Password, then restart the tunnel:" >&2
        if [ "$(uname -s)" = Darwin ]; then
          echo "  launchctl kickstart -k gui/\$(id -u)/org.nix-community.home.jumphost-socks5-proxy" >&2
        else
          echo "  systemctl --user restart jumphost-socks5-proxy" >&2
        fi
        exit 1
      fi
      export ALL_PROXY=socks5://127.0.0.1:${toString socksPort}
      export HTTPS_PROXY=socks5://127.0.0.1:${toString socksPort}
      export HTTP_PROXY=socks5://127.0.0.1:${toString socksPort}
      export PU_HOST=${puHost}
      # Apple /usr/bin/ssh is SIP-protected and ignores DYLD_INSERT_LIBRARIES.
      # Nix OpenSSH is the one proxychains can actually hook.
      export PATH="${lib.getBin pkgs.openssh}/bin:$PATH"
      exec ${lib.getExe' pkgs.proxychains-ng "proxychains4"} -q -f ${conf} "$@"
    '')
  ];
}
