{ pkgs, ... }:
{
  imports = [
    ../../modules/home/cli/git.nix
  ];

  home.username = "toor";
  home.stateVersion = "24.05";

  systemd.user.services.hello = {
    Unit.Description = "Hello service";

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.hello}/bin/hello";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
