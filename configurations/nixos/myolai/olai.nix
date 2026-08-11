# olai home-manager config for the myolai container (its only user).
{ flake, config, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.olai.homeManagerModules.default
  ];

  services.olai = {
    enable = true;
    # Dropbox's real sync dir: the home-manager dropbox module runs the
    # daemon under the ~/.dropbox-hm fake home.
    dataDir = "${config.home.homeDirectory}/.dropbox-hm/Dropbox/MyOlai";
    # Loopback-only; published on the tailnet by `tailscale serve`
    # (incus.servePort in ./default.nix).
    host = "127.0.0.1";
    # Free of common tool ports.
    port = 7733;
  };
}
