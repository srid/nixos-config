{
  services.xserver.xkb.options = "ctrl:nocaps";
  services.libinput = {
    mouse.naturalScrolling = true;
    touchpad.naturalScrolling = true;
  };

  # KDE Wayland uses KConfig rather than the Xorg libinput settings above.
  environment.etc."xdg/kxkbrc".text = ''
    [Layout]
    Options=ctrl:nocaps
    ResetOldOptions=true
  '';
  environment.etc."xdg/kcminputrc".text = ''
    [Libinput][Defaults][Pointer]
    NaturalScroll=true

    [Libinput][Defaults][Touchpad]
    NaturalScroll=true
    # Halve two-finger scroll distance for finer control on the XPS touchpad.
    ScrollFactor=0.5
  '';
}
