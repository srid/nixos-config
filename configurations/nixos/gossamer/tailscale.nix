{ flake, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--operator=${flake.config.me.username}" ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 7692 ];

  home-manager.sharedModules = [
    {
      xdg.configFile."autostart/tailscale-systray.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Tailscale
        Exec=${pkgs.tailscale}/bin/tailscale systray
        Terminal=false
        OnlyShowIn=KDE;
      '';
    }
  ];
}
