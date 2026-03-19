# Juspay LLM provider for opencode (via grid.ai.juspay.net)
# Import this module alongside ./default.nix to use Juspay models.
{ config, flake, ... }:
let
  inherit (flake) self;
in
{
  age.secrets.juspay-anthropic-api-key.file = self + /secrets/juspay-anthropic-api-key.age;

  programs.zsh.initContent = ''
    export JUSPAY_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
  programs.bash.initExtra = ''
    export JUSPAY_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
}
