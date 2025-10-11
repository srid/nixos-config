{
  # Mirroring configuration from https://github.com/juspay/vertex
  home.sessionVariables = {
    # Enable Vertex AI integration
    CLAUDE_CODE_USE_VERTEX = "1";
    CLOUD_ML_REGION = "us-east5";
    ANTHROPIC_VERTEX_PROJECT_ID = "dev-ai-gamma";

    # Optional: Disable prompt caching if needed
    DISABLE_PROMPT_CACHING = "1";

    # Optional: Override regions for specific models
    VERTEX_REGION_CLAUDE_3_5_HAIKU = "us-central1";
    VERTEX_REGION_CLAUDE_3_5_SONNET = "us-east5";
    VERTEX_REGION_CLAUDE_3_7_SONNET = "us-east5";
    VERTEX_REGION_CLAUDE_4_0_OPUS = "europe-west4";
    VERTEX_REGION_CLAUDE_4_0_SONNET = "us-east5";

    # Model configuration
    ANTHROPIC_MODEL = "claude-sonnet-4-5";
    ANTHROPIC_SMALL_FAST_MODEL = "claude-3-5-haiku";
  };
}
