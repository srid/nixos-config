{ inputs, ... }:
let
  inherit (inputs) landrun-nix;
  inherit (landrun-nix) landrunModules;
in
{
  imports = [ landrun-nix.flakeModule ];

  perSystem = { pkgs, ... }: {
    landrunApps.claude = {
      program = "${pkgs.claude-code}/bin/claude";
      imports = [
        landrunModules.gh
        landrunModules.git
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
        ];
        rwx = [ "." ];
        env = [
          "HOME" # Needed for gcloud and claude to resolve ~/ paths for config/state files
          "CLAUDE_CODE_USE_VERTEX"
          "ANTHROPIC_MODEL"
        ];
      };
    };
  };
}
