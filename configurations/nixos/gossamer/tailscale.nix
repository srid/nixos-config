{ flake, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--operator=${flake.config.me.username}" ];
  };

  # Kolu is served from pureintent now; gossamer only needs plain tailnet
  # access plus the tray applet below.
  home-manager.sharedModules = [
    {
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
