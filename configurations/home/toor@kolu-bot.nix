{ pkgs, flake, config, lib, ... }:
let
  githubUsers = [
    "srid"
    "shivaraj-bh"
    "subanesh-swe"
  ];
  caddyfile = pkgs.writeText "Caddyfile" ''
    {
      admin off
      auto_https off
    }

    :8080 {
      bind 127.0.0.1
      reverse_proxy 127.0.0.1:${toString config.services.olai.port}
    }
  '';
in
{
  imports = [
    (flake.inputs.self + /modules/home/work/opencode.nix)
    (flake.inputs.self + /modules/home/work/pi.nix)
    flake.inputs.olai.homeManagerModules.default
  ];

  home.username = "toor";
  home.stateVersion = "24.05";

  # opencode.nix exports JUSPAY_API_KEY via programs.bash.initExtra; that
  # only ships if HM manages bash (this host is standalone, not NixOS-HM).
  programs.bash.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "olai";
      email = "olai";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."github.com" = {
      IdentityFile = "~/.ssh/nix-team-olai";
      IdentitiesOnly = "yes";
    };
  };

  services.olai = {
    enable = true;
    dataDir = "${config.home.homeDirectory}/nix-team-olai";
    host = "127.0.0.1";
    commit = "auto";
    push = "auto";
    plugins = [ "kolu" "odu" "xyne-spaces" ];
  };

  # Literal path: systemd EnvironmentFile does not expand $XDG_RUNTIME_DIR.
  age.secrets.juspay-anthropic-api-key.path =
    "${config.home.homeDirectory}/.config/agenix/juspay-anthropic-api-key";

  # The age file is the raw key (bashrc `cat`s it). systemd EnvironmentFile
  # wants KEY=value, so write that next to the decrypt. Olai's ExecStart stays
  # the module's.
  systemd.user.services.agenix.Service.ExecStartPost =
    let
      envFile = "${config.home.homeDirectory}/.config/agenix/olai-juspay.env";
      script = pkgs.writeShellScript "olai-juspay-env" ''
        set -euo pipefail
        umask 077
        ${pkgs.coreutils}/bin/printf 'JUSPAY_API_KEY=%s\n' "$(${pkgs.coreutils}/bin/tr -d '\n' < "$1")" > "$2"
      '';
    in
    "${script} ${config.age.secrets.juspay-anthropic-api-key.path} ${envFile}";

  # Standalone HM: systemd --user was not started from a NixOS login, so the
  # manager PATH is only systemd's bindir (naiveintent/myolai inherit the
  # session PATH). environment.d is read at manager start; set-environment
  # updates the already-running instance without restarting the user session.
  systemd.user.sessionVariables.PATH = lib.concatStringsSep ":" [
    "${config.home.profileDirectory}/bin"
    "/run/wrappers/bin"
    "/nix/var/nix/profiles/default/bin"
    "/run/current-system/sw/bin"
  ];

  home.activation.systemdUserPath = lib.hm.dag.entryBefore [ "reloadSystemd" ] ''
    ${lib.getExe' pkgs.systemd "systemctl"} --user set-environment \
      PATH=${lib.escapeShellArg config.systemd.user.sessionVariables.PATH}
  '';

  age.secrets."olai-spaces.env" = {
    file = flake.inputs.self + /secrets/olai-spaces.env.age;
    path = "${config.home.homeDirectory}/.config/agenix/olai-spaces.env";
  };

  systemd.user.services.olai = {
    Unit.After = [ "agenix.service" ];
    # Two files: systemd EnvironmentFile does not expand $XDG_RUNTIME_DIR,
    # and a single string would drop the JUSPAY_API_KEY file the module
    # does not know about.
    Service.EnvironmentFile = [
      "${config.home.homeDirectory}/.config/agenix/olai-juspay.env"
      config.age.secrets."olai-spaces.env".path
    ];
  };

  age.secrets."oauth2-proxy.env" = {
    file = flake.inputs.self + /secrets/oauth2-proxy.env.age;
    path = "${config.home.homeDirectory}/.config/agenix/oauth2-proxy.env";
  };

  home.packages = [
    pkgs.caddy
    pkgs.oauth2-proxy
    flake.inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  systemd.user.services.caddy = {
    Unit = {
      Description = "Caddy reverse proxy to olai";
      After = [ "network.target" "olai.service" ];
    };
    Service = {
      ExecStart = "${pkgs.caddy}/bin/caddy run --config ${caddyfile} --adapter caddyfile";
      Restart = "on-failure";
      RestartSec = "2s";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.oauth2-proxy = {
    Unit = {
      Description = "oauth2-proxy (GitHub login)";
      After = [ "network.target" "caddy.service" "agenix.service" ];
    };
    Service = {
      EnvironmentFile = config.age.secrets."oauth2-proxy.env".path;
      ExecStart = lib.concatStringsSep " " ([
        "${pkgs.oauth2-proxy}/bin/oauth2-proxy"
        "--provider=github"
        "--email-domain=*"
        "--redirect-url=https://kolu-bot.rooster-blues.ts.net/oauth2/callback"
        "--upstream=http://127.0.0.1:8080"
        "--http-address=127.0.0.1:4180"
        "--reverse-proxy=true"
        "--cookie-secure=true"
        "--cookie-samesite=lax"
      ] ++ map (u: "--github-user=${u}") githubUsers);
      Restart = "on-failure";
      RestartSec = "2s";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
