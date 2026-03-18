{ config, flake, pkgs, ... }:
let
  inherit (flake) self;
in
{
  imports = [
    flake.inputs.oc.homeModules.default
    flake.inputs.nix-agent-wire.homeModules.opencode
  ];

  age.secrets.juspay-anthropic-api-key.file = self + /secrets/juspay-anthropic-api-key.age;

  programs.opencode = {
    package = flake.inputs.oc.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
    autoWire.dirs = [
      flake.inputs.skills.outPath
      (flake.self.outPath + "/AI")
    ];
  };

  programs.zsh.initContent = ''
    export JUSPAY_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
    export OPENCODE_DISABLE_CLAUDE_CODE=1
  '';
  programs.bash.initExtra = ''
    export JUSPAY_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
    export OPENCODE_DISABLE_CLAUDE_CODE=1
  '';
}
