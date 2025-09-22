# This machine uses Omarchy
#
# So we consciously pick what we need
{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  imports = [
    "${homeMod}/claude-code"
    "${homeMod}/all/git.nix"
    "${homeMod}/all/just.nix"
    "${homeMod}/all/direnv.nix"
    "${homeMod}/all/starship.nix"
    "${homeMod}/all/bash.nix"
    "${homeMod}/all/terminal.nix"
  ];

  # Bash custom configuration
  programs.bash = {
    # Not using this ^ because our starship provides direnv integration.
    # bashrcExtra = ''
    #   # Omarchy integration
    #   source ~/.local/share/omarchy/default/bash/rc
    # '';
  };

  # For Zed's Claude Code to work with Anthropic Vertex
  home.sessionVariables = {
    CLAUDE_CODE_USE_VERTEX = "1";
    ANTHROPIC_VERTEX_PROJECT_ID = "dev-ai-delta";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        extraOptions = {
          # Configure SSH to use 1Password agent
          IdentityAgent = "~/.1password/agent.sock";
        };
      };
      "pureintent" = {
        forwardAgent = true;
      };
      "sincereintent" = {
        forwardAgent = true;
      };
    };
  };

  home.username = "srid";
  home.stateVersion = "25.05";
}
