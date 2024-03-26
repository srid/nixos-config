{ pkgs, ... }:

{
  # Github runner CI
  users = {
    knownUsers = [ "github-runner" ];
    forceRecreate = true;
    users.github-runner = {
      uid = 1009;
      description = "GitHub Runner";
      home = "/Users/github-runner";
      createHome = true;
      shell = pkgs.bashInteractive;
      # NOTE: Go to macOS Remote-Login settings and allow all users to ssh.
      openssh.authorizedKeys.keys = [
        # github-runner VM's /etc/ssh/ssh_host_ed25519_key.pub
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJUJvyuUnIs2q2TkJq29wqJ6HyOAeMmIK8PcH7xAlpVY root@github-runner"
      ];
    };
  };
  nix.settings.trusted-users = [ "github-runner" ];
}
