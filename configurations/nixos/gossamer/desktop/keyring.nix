{
  # Plasma supplies this helper and SDDM's PAM wallet integration. Its XDG
  # autostart entry has X-systemd-skip=true, so Niri needs an explicit dependency
  # to pass the session environment to the wallet waiting on the PAM socket.
  systemd.user.services.plasma-kwallet-pam = {
    overrideStrategy = "asDropin";
    enableDefaultPath = false;
    wantedBy = [ "niri.service" ];
    after = [ "niri.service" ];
  };
}
