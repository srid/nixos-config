{ config, pkgs, ... }:
let
  caffeine =
    pkgs.writeScriptBin "caffeine"
      '' 
        #!${pkgs.runtimeShell}
        set -xe
        HOURS=$*
        SECS=`expr 1 + 60 \* 60 \* $HOURS`
        date
        ${pkgs.xautolock}/bin/xautolock -disable
        ${pkgs.cowsay}/bin/cowsay "Autolock de-activated for next $HOURS hours"
        sleep $SECS
        date
        ${pkgs.xautolock}/bin/xautolock -enable
        ${pkgs.cowsay}/bin/cowsay "Autolock re-activated."
      '';
in
{
  services.xserver.xautolock = {
    enable = true;
    time = 5; # mins

    # Some modes freeze P71, so explicitly select a mode that is known to be stable.
    locker = "${pkgs.xlockmore}/bin/xlock -mode space";

    # Suspend after lock. 
    killtime = 10; # mins
    killer = "${pkgs.systemd}/bin/systemctl suspend";
  };

  environment.systemPackages = [
    # TODO: replace this with https://github.com/jD91mZM2/xidlehook
    #
    # A script to disable auto-suspend until unlocking the computer the next
    # time. The idea is to leave this running on desktop, whilst taking my
    # laptop to another room and ssh to the desktop.
    (pkgs.writeScriptBin "estivate"
      '' 
        #!${pkgs.runtimeShell}
        set -xe
        date
        ${pkgs.xautolock}/bin/xautolock -disable
        ${pkgs.xlockmore}/bin/xlock -mode blank
        date
        ${pkgs.xautolock}/bin/xautolock -enable
        ${pkgs.cowsay}/bin/cowsay "Welcome back!"
      '')
    # Run this before watching a movie
    (pkgs.writeScriptBin "caffeine-2hr"
      '' 
        #!${pkgs.runtimeShell}
        set -xe
        ${caffeine} 2
      '')
    caffeine
  ];
}
