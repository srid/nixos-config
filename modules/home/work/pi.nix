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
        case " $* " in
          *" --model "*) exec ${lib.getExe pi} "$@" ;;
          *) exec ${lib.getExe pi} --model litellm/kimi-k3 "$@" ;;
        esac
      '';
    })
  ];
}
