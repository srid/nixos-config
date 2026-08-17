# `juspay-run` + proxychains over the jumphost SOCKS5
# (https://github.com/srid/jumphost-nix). See modules/home/work/juspay.nix.
{ config, flake, pkgs, ... }:

let
  socksPort = config.home-manager.users.${flake.config.me.username}.programs.jumphost.socks5Proxy.port;
  proxychainsBin = "${config.programs.proxychains.package}/bin/proxychains4";
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

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "juspay-run" ''
      export ALL_PROXY=socks5://127.0.0.1:${toString socksPort}
      export HTTPS_PROXY=socks5://127.0.0.1:${toString socksPort}
      export HTTP_PROXY=socks5://127.0.0.1:${toString socksPort}
      exec ${proxychainsBin} "$@"
    '')
  ];
}
