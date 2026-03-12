let
  models = import ./models.nix;
in
{
  npm = "@ai-sdk/openai-compatible";
  name = "Juspay";
  options = {
    baseURL = "https://grid.ai.juspay.net";
    # HACK: hardcoded path to agenix secret. Should use XDG_RUNTIME_DIR but
    # OpenCode's {file:...} doesn't support environment variable expansion.
    apiKey = "{file:/run/user/1000/agenix/juspay-anthropic-api-key}";
    timeout = 600000;
  };
  inherit models;
}
