{ pkgs, ... }:
let
  restartChrome = pkgs.writeShellApplication {
    name = "restart-chrome";
    runtimeInputs = [
      pkgs.python3
      pkgs.niri
      pkgs.libnotify
    ];
    text = ''
      exec python3 ${./restart.py} "$@"
    '';
  };
in
{
  environment.systemPackages = [ restartChrome ];
  home-manager.sharedModules = [
    {
      # Niri uses this desktop identifier, but desktop-file-validate does not
      # yet recognize it in OnlyShowIn (also used by our Tailscale autostart).
      xdg.dataFile."applications/restart-chrome.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Restart Chrome
        Comment=Restore Chrome tabs and open web apps using the current installation
        Exec=${restartChrome}/bin/restart-chrome
        Icon=google-chrome
        Terminal=false
        Categories=Network;WebBrowser;
        OnlyShowIn=niri;
      '';
    }
  ];

}
