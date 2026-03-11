{
  open-large = {
    name = "open-large";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 202752;
      output = 32000;
    };
  };
  open-fast = {
    name = "open-fast";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 196000;
      output = 32000;
    };
  };
  open-vision = {
    name = "open-vision";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 262144;
      output = 32000;
    };
  };
  claude-opus-4-5 = {
    name = "claude-opus-4-5";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 1000000;
      output = 128000;
    };
  };
  claude-opus-4-6 = {
    name = "claude-opus-4-6";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 1000000;
      output = 128000;
    };
  };
  claude-sonnet-4-6 = {
    name = "claude-sonnet-4-6";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 200000;
      output = 64000;
    };
  };
  claude-sonnet-4-5 = {
    name = "claude-sonnet-4-5";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 200000;
      output = 32000;
    };
  };
  glm-flash-experimental = {
    name = "glm-flash-experimental";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 262144;
      output = 32000;
    };
  };
  gemini-3-pro-preview = {
    name = "gemini-3-pro-preview";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 1048576;
      output = 65535;
    };
  };
  gemini-3-flash-preview = {
    name = "gemini-3-flash-preview";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 1048576;
      output = 65535;
    };
  };
  minimax-m2 = {
    name = "minimax-m2";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 202752;
      output = 32000;
    };
  };
  glm-latest = {
    name = "glm-latest";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 202752;
      output = 32000;
    };
  };
  kimi-latest = {
    name = "kimi-latest";
    modalities = {
      input = [ "text" "image" ];
      output = [ "text" ];
    };
    limit = {
      context = 262000;
      output = 32000;
    };
  };
}
