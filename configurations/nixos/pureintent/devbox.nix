# Depends on programs.jumphost.socks5Proxy (https://github.com/srid/jumphost-nix)
# for the local SOCKS5 listener. See modules/home/work/juspay.nix:29-31.
{ config, flake, pkgs, ... }:

let
  socksPort = config.home-manager.users.${flake.config.me.username}.programs.jumphost.socks5Proxy.port;

  proxychainsBin = "${config.programs.proxychains.package}/bin/proxychains4";

  devbox-run = pkgs.writeShellScriptBin "devbox-run" ''
    export ALL_PROXY=socks5://127.0.0.1:${toString socksPort}
    export HTTPS_PROXY=socks5://127.0.0.1:${toString socksPort}
    export HTTP_PROXY=socks5://127.0.0.1:${toString socksPort}
    exec ${proxychainsBin} "$@"
  '';
in
{
  programs.proxychains = {
    enable = true;
    chain.type = "strict";
    proxyDNS = true;
    proxies.devbox = {
      enable = true;
      type = "socks5";
      host = "127.0.0.1";
      port = socksPort;
    };
  };

  environment.systemPackages = [
    devbox-run
  ];
}
