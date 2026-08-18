# proxychains-wrapped pu / xyne-boxes. Pulls in juspay-run.nix for the
# jumphost SOCKS5 + proxychains.
{ config, flake, pkgs, ... }:

let
  socksPort = config.home-manager.users.${flake.config.me.username}.programs.jumphost.socks5Proxy.port;
  proxychainsBin = "${config.programs.proxychains.package}/bin/proxychains4";
  xbPkg = flake.inputs.xyne-boxes.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # Context: https://github.com/juspay/xyne-boxes/pull/14#issuecomment-4918563982
  puHost = "10.10.68.56";

  wrap = name: pkgs.writeShellScriptBin name ''
    export ALL_PROXY=socks5://127.0.0.1:${toString socksPort}
    export HTTPS_PROXY=socks5://127.0.0.1:${toString socksPort}
    export HTTP_PROXY=socks5://127.0.0.1:${toString socksPort}
    export PU_HOST=${puHost}
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
