{ pkgs, flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.darwinModules.default
    "${self}/nix-darwin/zsh-completion-fix.nix"
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

  networking.hostName = "appreciate";
  age.secrets."github-nix-ci/srid.token.age" = {
    file = ../secrets/github-nix-ci/srid.token.age;
    owner = "_github-runner";
  };
  services.github-nix-ci = {
    personalRunners = {
      "srid/nixos-config".num = 1;
    };
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
