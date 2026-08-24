# Same package as `nix run github:juspay/AI#pi-juspay-oneclick`. Default
# model matches opencode.nix; CLI --model still overrides. JUSPAY_API_KEY
# comes from ./opencode.nix (the wrapper also prompts if unset).

{ flake, pkgs, lib, ... }:
let
  pi =
    flake.inputs.juspay-ai.packages.${pkgs.stdenv.hostPlatform.system}.pi-juspay-oneclick;
in
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "pi";
      text = ''
        has_model=0
        for arg in "$@"; do
          if [ "$arg" = "--model" ]; then
            has_model=1
            break
          fi
        done
        if [ "$has_model" -eq 0 ]; then
          exec ${lib.getExe pi} --model litellm/kimi-k3 "$@"
        fi
        exec ${lib.getExe pi} "$@"
      '';
    })
  ];
}
