{ ... }:
let
  controlMasterOpts = {
    ControlMaster = "auto";
    ControlPath = "~/.ssh/sockets/%r@%h-%p";
    ControlPersist = "900";
  };
in
{
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.matchBlocks = {
    "pureintent".extraOptions = controlMasterOpts;
    "sincereintent".extraOptions = controlMasterOpts;
    "zest".extraOptions = controlMasterOpts;
  };
}
