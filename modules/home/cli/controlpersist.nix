{ lib, ... }:
{
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.settings = lib.genAttrs [ "pureintent" "sincereintent" "zest" ] (_: {
    ControlMaster = "auto";
    ControlPath = "~/.ssh/sockets/%r@%h-%p";
    ControlPersist = "900";
  });
}
