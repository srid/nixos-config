{ config, flake, pkgs, ... }:
{
  imports = [ flake.inputs.oc.homeModules.default ];
  programs.opencode.package = flake.inputs.oc.packages.${pkgs.stdenv.hostPlatform.system}.default;

  programs.zsh.initContent = ''
    export JUSPAY_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
  programs.bash.initExtra = ''
    export JUSPAY_API_KEY="$(cat "${config.age.secrets.juspay-anthropic-api-key.path}")"
  '';
}
