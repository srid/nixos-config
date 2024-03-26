{ pkgs, flake, ... }:

# See nix-darwin/default.nix for other modules in use.
{
  imports = [
    flake.inputs.self.darwinModules.default
    ../nix-darwin/ci/github-runner.nix
    ../nix-darwin/zsh-completion-fix.nix
  ];

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

  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.systemPackages = with pkgs; [
    # macOS GUI programs
    # wezterm
  ];

  security.pam.enableSudoTouchIdAuth = true;

  # For home-manager to work.
  users.users.${flake.config.people.myself} = {
    name = flake.config.people.myself;
    home = "/Users/${flake.config.people.myself}";
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
