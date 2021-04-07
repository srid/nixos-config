{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.protonmail-bridge ];
  services.gnome3.gnome-keyring.enable = true;

  # Before starting the service, use `protonmail-bridge --cli` and run 'login'
  # to configure.
  systemd.user.services.protonmail-bridge = {
    description = "Protonmail Bridge";
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    path = [ pkgs.pass ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive";
    };
  };
}
