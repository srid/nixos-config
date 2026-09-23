{ pkgs, lib, ... }:
let
  input = import ./input-preferences.nix;
in
{
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = input.keyboardLayout;
    options = input.keyboardOptions;
  };
  services.libinput = {
    mouse.naturalScrolling = input.naturalScrolling;
    touchpad.naturalScrolling = input.naturalScrolling;
  };
  # KDE Wayland reads KConfig rather than the Xorg libinput settings.
  environment.etc."xdg/kxkbrc".text = ''
    [Layout]
    Options=${input.keyboardOptions}
    ResetOldOptions=true
  '';
  environment.etc."xdg/kcminputrc".text = ''
    [Libinput][Defaults][Pointer]
    NaturalScroll=${lib.boolToString input.naturalScrolling}

    [Libinput][Defaults][Touchpad]
    NaturalScroll=${lib.boolToString input.naturalScrolling}
    ScrollFactor=${toString input.touchpadScrollFactor}
  '';

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
