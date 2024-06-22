{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.darwinModules.default
    "${self}/nix-darwin/zsh-completion-fix.nix"
    "${self}/nixos/github-runner.nix"
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "appreciate";

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
