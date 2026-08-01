{ ... }:
{
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.settings = {
    pureintent = {
      ControlMaster = "auto";
      ControlPath = "~/.ssh/sockets/%r@%h-%p";
      ControlPersist = "900";
    };
    sincereintent = {
      ControlMaster = "auto";
      ControlPath = "~/.ssh/sockets/%r@%h-%p";
      ControlPersist = "900";
    };
    zest = {
      ControlMaster = "auto";
      ControlPath = "~/.ssh/sockets/%r@%h-%p";
      ControlPersist = "900";
    };
  };
}
