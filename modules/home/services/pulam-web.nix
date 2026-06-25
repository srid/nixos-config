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
        # "localhost" (not "local") is the in-process host — only
        # localhost/127.0.0.1/::1 skip ssh; "local" would be dialed as a remote.
        PULAM_WEB_HOSTS = "pureintent,localhost";
        # zest itself runs kolu, which means several kaval daemons — pulam can't
        # guess which to read and would render "no terminals", so we name the
        # kolu-server socket explicitly. On macOS it lives at
        # /tmp/kaval-<port>-<uid>/pty-host.sock; port 7692 (services.kolu), uid
        # 501. See the pulam-web README, "Pointing at a host that runs kolu?".
        PULAM_WEB_KAVAL_SOCKETS = "localhost=/tmp/kaval-7692-501/pty-host.sock";
      };
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/pulam-web.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/pulam-web.err";
    };
  };
}
