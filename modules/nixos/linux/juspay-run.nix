# System proxychains.conf + package for Linux wrappers (devbox.nix).
# The `juspay-run` binary lives in modules/home/work/juspay-run.nix.
{ config, flake, ... }:

let
  socksPort = config.home-manager.users.${flake.config.me.username}.programs.jumphost.socks5Proxy.port;
in
{
  programs.proxychains = {
    enable = true;
    quietMode = true;
    chain.type = "strict";
    proxyDNS = true;
    proxies.devbox = {
      enable = true;
      type = "socks5";
      host = "127.0.0.1";
      port = socksPort;
    };
  };
}
