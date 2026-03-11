let
  models = import ./models.nix;
in
{
  npm = "@ai-sdk/openai-compatible";
  name = "Juspay";
  options = {
    baseURL = "https://grid.ai.juspay.net";
    apiKey = "{env:JUSPAY_API_KEY}";
    timeout = 600000;
  };
  inherit models;
}
