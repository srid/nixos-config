{ flake, pkgs, ... }:
{
  imports = [
    flake.inputs.oc.homeModules.opencode
  ];

  programs.opencode = {
    package = flake.inputs.oc.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
    autoWire.dirs = [
      flake.inputs.skills.outPath
      (flake.self.outPath + "/AI")
    ];
    settings = {
      model = "anthropic/claude-opus-4-6/max";
    };
  };

  # Prevent opencode from delegating to Claude Code when it's installed
  programs.zsh.initContent = ''
    export OPENCODE_DISABLE_CLAUDE_CODE=1
  '';
  programs.bash.initExtra = ''
    export OPENCODE_DISABLE_CLAUDE_CODE=1
  '';
}
