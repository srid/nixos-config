# Configuration common to all macOS systems
{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  imports = [
    {
      # For home-manager to work.
      users.users.${flake.config.me.username} = {
        home = "/Users/${flake.config.me.username}";
      };
      home-manager.users.${config.me.username} = { };
      home-manager.sharedModules = [
        inputs.nix-index.homeManagerModules.${pkgs.system}.default
        self.homeModules.default
        self.homeModules.darwin-only
      ];
    }
    self.nixosModules.common
    inputs.agenix.darwinModules.default
    ./all/zsh-completion-fix.nix
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
}
