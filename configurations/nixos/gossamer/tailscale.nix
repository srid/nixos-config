{ flake, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--operator=${flake.config.me.username}" ];
  };

  # olai stays bound to 127.0.0.1. Its tailnet door is `tailscale serve`
  # (modules/nixos/tailscale-serve.nix), which terminates TLS with this node's
  # own certificate and injects the `Tailscale-User-*` headers olai's identity
  # row reads. The address is https://gossamer.rooster-blues.ts.net/.
  tailscaleServe.olai.port = flake.inputs.olai.lib.defaultPort;

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
