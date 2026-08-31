# olai home-manager config for the myolai container (its only user).
{ flake, config, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.olai.homeManagerModules.default
  ];

  services.olai = {
    enable = true;
    # Local outlines dir (dropbox is disabled for now; when it returns,
    # its real sync dir is ~/.dropbox-hm/Dropbox/<folder>).
    dataDir = "${config.home.homeDirectory}/Vault";
    # Loopback-only; published on the tailnet by `tailscale serve`
    # (incus.servePort in ./default.nix).
    host = "127.0.0.1";
    # Free of common tool ports.
    port = 7733;
    commit = "auto";
    push = "auto";
    plugins = [ ];
  };
}
