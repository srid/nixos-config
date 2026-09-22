{ pkgs, ... }:

{
  services.hardware.bolt.enable = true;
  environment.systemPackages = [ pkgs.asdbctl ];
  services.udev.packages = [ pkgs.asdbctl ];

  home-manager.sharedModules = [
    {
      xdg.dataFile."kglobalaccel/studio-display-brightness.desktop" = {
        executable = true;
        text = ''
          [Desktop Entry]
          Type=Application
          Name=Studio Display Brightness
          Exec=${pkgs.asdbctl}/bin/asdbctl get
          X-KDE-GlobalShortcutType=Service
          Actions=Dimmer;Brighter;

          [Desktop Action Dimmer]
          Name=Dim Studio Display
          Exec=${pkgs.asdbctl}/bin/asdbctl down
          X-KDE-Shortcuts=Meta+F1

          [Desktop Action Brighter]
          Name=Brighten Studio Display
          Exec=${pkgs.asdbctl}/bin/asdbctl up
          X-KDE-Shortcuts=Meta+F2
        '';
      };
    }
  ];
}
