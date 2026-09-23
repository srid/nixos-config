{ flake, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--operator=${flake.config.me.username}" ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 7692 ];

  # Serve the node's HTTPS name privately within the tailnet (not Funnel).
  # services.tailscale.serve manages named Tailscale Services instead.
  systemd.services.tailscale-serve-kolu = {
    description = "Serve Kolu over tailnet HTTPS";
    after = [ "tailscaled.service" "tailscaled-set.service" ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    # tailscaled can be active before its backend reaches Running. Keep
    # retrying through startup/offline periods instead of failing until reboot.
    startLimitIntervalSec = 0;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "5s";
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --https=443 http://127.0.0.1:7692";
      ExecStop = "${pkgs.tailscale}/bin/tailscale serve --https=443 off";
    };
  };

  home-manager.sharedModules = [
    {
      services.kolu.allowedOrigins = [ "https://gossamer.rooster-blues.ts.net" ];
      xdg.configFile."autostart/tailscale-systray.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Tailscale
        Exec=${pkgs.tailscale}/bin/tailscale systray
        Terminal=false
        OnlyShowIn=KDE;niri;
      '';
    }
  ];
}
