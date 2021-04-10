{ config, pkgs, ... }:

{
  services.xserver.xautolock = {
    enable = true;
    time = 5; # mins

    # Not sure if some modes are the cause of system freeze
    # So deterministically pick one.
    locker = "${pkgs.xlockmore}/bin/xlock -mode space";

    # Suspend after sometime (enable this after things are okay)
    killtime = 20; # mins
    killer = "${pkgs.systemd}/bin/systemctl suspend";
  };
}
