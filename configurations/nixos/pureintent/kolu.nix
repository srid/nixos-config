{ flake, ... }:

{
  # Kolu moved here from the gossamer workstation: a single always-on host
  # serves the web UI for every terminal, so it no longer depends on a laptop
  # being awake. `linger` is already enabled in default.nix, so the user
  # service starts at boot without a login session.
  home-manager.sharedModules = [
    (flake.inputs.self + /modules/home/services/kolu.nix)
    {
      # Bind on all interfaces: the local hostname resolves to 127.0.0.2 on
      # pureintent, so loopback alone would not answer. Remote access is
      # limited to the tailnet by the firewall rule below.
      services.kolu.host = "0.0.0.0";
      services.kolu.allowedOrigins = [ "https://pureintent.rooster-blues.ts.net" ];
    }
  ];

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 7692 ];

  # Serve the node's HTTPS name privately within the tailnet (not Funnel).
  # services.tailscale.serve manages named Tailscale Services instead.
  tailscaleServe.kolu.port = 7692;
}
