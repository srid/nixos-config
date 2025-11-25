# Juspay-specific configuration using the work jump host module
#
# Debug agenix logs:
#   cat ~/Library/Logs/agenix/stdout
#   cat ~/Library/Logs/agenix/stderr

{ flake, config, ... }:
let
  inherit (flake) self;
  inherit (flake.inputs) jumphost-nix;
in
{
  imports = [
    "${jumphost-nix}/module.nix"
  ];

  # https://github.com/srid/jumphost-nix
  programs.jumphost = {
    enable = true;
    host = "vanjaram.tail12b27.ts.net";

    sshHosts = {
      "ssh.bitbucket.juspay.net".user = "git";
    };

    git = {
      baseCodeDir = "~/juspay";
      email = "sridhar.ratnakumar@juspay.in";
    };

    socks5Proxy = {
      enable = true;
    };
  };

  # For Juspay LiteLLM AI configuration
  home.sessionVariables = {
    ANTHROPIC_BASE_URL = "https://grid.ai.juspay.net";
    ANTHROPIC_MODEL = "claude-sonnet-4-5";
    # ANTHROPIC_API_KEY set in initExtra via agenix (see below)
  };
  age = {
    secrets = {
      juspay-anthropic-api-key.file = self + /secrets/juspay-anthropic-api-key.age;
    };
  };
  programs.zsh.initContent = ''
    export ANTHROPIC_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
  programs.bash.initExtra = ''
    export ANTHROPIC_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
}
