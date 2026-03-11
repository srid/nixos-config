{ flake, config, ... }:
let
  inherit (flake) self;
in
{
  imports = [
    ../agenix.nix
  ];

  home.sessionVariables = {
    ANTHROPIC_BASE_URL = "https://grid.ai.juspay.net";
    ANTHROPIC_MODEL = "claude-sonnet-4-5";
    CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = "1";
  };

  age.secrets.juspay-anthropic-api-key.file = self + /secrets/juspay-anthropic-api-key.age;

  programs.zsh.initContent = ''
    export ANTHROPIC_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
  programs.bash.initExtra = ''
    export ANTHROPIC_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
}
