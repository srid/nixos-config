{ pkgs, flake, ... }:

# See nix-darwin/default.nix for other modules in use.
{
  imports = [
    flake.inputs.self.darwinModules.default
    ../nix-darwin/ci/github-runner.nix
    ../nix-darwin/zsh-completion-fix.nix
  ];

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
