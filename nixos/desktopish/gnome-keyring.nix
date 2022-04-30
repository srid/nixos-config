{ pkgs, ... }: {
  services.gnome.at-spi2-core.enable = true; # Not sure what this is for.

  # https://unix.stackexchange.com/a/434752
  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true; # keyring GUI
}
