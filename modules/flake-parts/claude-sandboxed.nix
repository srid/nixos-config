{ inputs, ... }:
let
  inherit (inputs) landrun-nix;
  inherit (landrun-nix) landrunModules;
in
{
  imports = [ landrun-nix.flakeModule ];

  perSystem = { pkgs, system, lib, ... }: {
    landrunApps.claude = lib.mkIf (lib.hasInfix "linux" system) {
      program = "${pkgs.claude-code}/bin/claude";
      imports = [
        landrunModules.gh
        landrunModules.git
        landrunModules.haskell
        landrunModules.markitdown
      ];
      features = {
        tty = true;
        nix = true;
        network = true;
      };
      cli = {
        rw = [
          # claude
          "$HOME/.claude"
          "$HOME/.claude.json"
          "$HOME/.config/gcloud"
          "$HOME/.cache/claude-cli-nodejs"
        ];
        rwx = [ "." ];
        env = [
          "HOME" # Needed for gcloud and claude to resolve ~/ paths for config/state files
          # See juspay.nix
          "ANTHROPIC_MODEL"
          "ANTHROPIC_API_KEY"
          "ANTHROPIC_BASE_URL"
        ];
      };
    };
  };
}
