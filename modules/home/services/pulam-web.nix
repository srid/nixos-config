{ flake, config, pkgs, ... }:

let
  inherit (flake) inputs;
  # Reuse the existing kolu flake input (pinned in flake.nix) — don't refetch.
  pulam-web = inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.pulam-web;
in
{
  # pulam-web from the kolu flake input, run as a launchd agent (macOS).
  # Equivalent to: PULAM_WEB_HOSTS=pureintent <kolu>#pulam-web — but the package
  # is referenced directly (no runtime `nix run`). The host list is machine
  # specific, so the consuming config sets the env below.
  launchd.agents.pulam-web = {
    enable = true;
    config = {
      ProgramArguments = [ "${pulam-web}/bin/pulam-web" ];
      EnvironmentVariables = {
        PULAM_WEB_HOSTS = "pureintent";
      };
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/pulam-web.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/pulam-web.err";
    };
  };
}
