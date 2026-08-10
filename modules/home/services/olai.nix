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
    # Personal outlines (default $OLAI_HOME). Must exist on the host;
    # Dropbox is not managed here.
    dataDir = "${config.home.homeDirectory}/Dropbox/MyOlai";
    # Free of common tool ports; bind address is host-specific (Tailscale
    # IP) so MagicDNS FQDN access works — set per host.
    port = 7733;
  };
}
