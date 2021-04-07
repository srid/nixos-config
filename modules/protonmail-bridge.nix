{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.protonmail-bridge ];
  services.gnome3.gnome-keyring.enable = true;
}
