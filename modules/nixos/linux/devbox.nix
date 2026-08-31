# proxychains-wrapped pu / xyne-boxes. Pulls in juspay-run.nix for the
# jumphost SOCKS5 + proxychains.
{ config, flake, pkgs, ... }:

let
  socksPort = config.home-manager.users.${flake.config.me.username}.programs.jumphost.socks5Proxy.port;
  proxychainsBin = "${config.programs.proxychains.package}/bin/proxychains4";
  xbPkg = flake.inputs.xyne-boxes.packages.${pkgs.stdenv.hostPlatform.system}.default;
  inherit (import (flake.inputs.self + /modules/work/pu.nix)) proxyEnv;

  wrap = name: pkgs.writeShellScriptBin name ''
    ${proxyEnv socksPort}
    exec ${proxychainsBin} ${xbPkg}/bin/${name} "$@"
  '';
in
{
  imports = [ ./juspay-run.nix ];

  environment.systemPackages = [
    (wrap "xyne-boxes")
    (wrap "pu")
  ];
}
