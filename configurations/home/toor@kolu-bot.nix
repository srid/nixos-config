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
  };

  age.secrets."oauth2-proxy.env" = {
    file = flake.inputs.self + /secrets/oauth2-proxy.env.age;
    path = "${config.home.homeDirectory}/.config/agenix/oauth2-proxy.env";
  };

  home.packages = [
    pkgs.caddy
    pkgs.oauth2-proxy
  ];

  systemd.user.services.caddy = {
    Unit = {
      Description = "Caddy reverse proxy to olai";
      After = [ "network.target" "olai.service" ];
      Requires = [ "olai.service" ];
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
      Requires = [ "caddy.service" "agenix.service" ];
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
