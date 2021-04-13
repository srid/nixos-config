{ config, pkgs, ... }:

{
  services.xserver.xautolock = {
    enable = true;
    time = 5; # mins

    # Not sure if some modes are the cause of system freeze
    # So deterministically pick one.
    locker = "${pkgs.xlockmore}/bin/xlock -mode space";

    # Suspend after sometime (enable this after things are okay)
    killtime = 10; # mins
    killer = "${pkgs.systemd}/bin/systemctl suspend";
  };

  environment.systemPackages = [
    # A script to disable auto-suspend until unlocking the computer the next
    # time. The idea is to leave this running on desktop, whilst taking my
    # laptop to another room and ssh to the desktop.
    (pkgs.writeScriptBin "estivate"
      '' 
        #!${pkgs.runtimeShell}
        set -xe
        date
        ${pkgs.xautolock}/bin/xautolock -disable
        ${pkgs.xlockmore}/bin/xlock
        date
        ${pkgs.xautolock}/bin/xautolock -enable
        ${pkgs.cowsay}/bin/cowsay "Welcome back!"
      '')
  ];
}
