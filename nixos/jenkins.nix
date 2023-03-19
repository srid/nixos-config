{ pkgs, config, ... }:

# HOWTO:
# - Goto http://localhost:8080/
#
# TODO:
# - Secrets (eg: cachix)
# - Build agents (SSH slave)
#    - NixOS slave: container separation?
#    - macOS slave (later)
# - Refactor
#   - Make this a nixos module, with `plugins` option (requires IFD?)?
let
  port = 9091;
  domain = "jenkins.srid.ca";
in
{
  age.secrets.jenkins-github-app-privkey = {
    owner = "jenkins";
    file = ../secrets/jenkins-github-app-privkey.age;
  };
  age.secrets.srid-cachix-auth-token = {
    owner = "jenkins";
    file = ../secrets/srid-cachix-auth-token.age;
  };
  services.jenkins = {
    enable = true;
    inherit port;
    environment = {
      CASC_JENKINS_CONFIG =
        let
          # https://github.com/jenkinsci/configuration-as-code-plugin/blob/master/docs/features/secrets.adoc#additional-variable-substitution
          cascReadFile = path:
            "$" + "{readFile:" + path + "}";
          cascJson = k: x:
            "$" + "{json:" + k + ":" + x + "}";
          # Template:
          # https://github.com/mjuh/nixos-jenkins/blob/master/nixos/modules/services/continuous-integration/jenkins/jenkins.nix
          cfg = {
            credentials = {
              system.domainCredentials = [
                {
                  credentials = [
                    {
                      # Instructions for creating this Github App are at:
                      # https://github.com/jenkinsci/github-branch-source-plugin/blob/master/docs/github-app.adoc#configuration-as-code-plugin
                      githubApp = {
                        appID = "307056"; # https://github.com/apps/jenkins-srid
                        description = "Github App - jenkins-srid";
                        id = "github-app";
                        privateKey = cascReadFile config.age.secrets.jenkins-github-app-privkey.path;
                      };
                    }
                    {
                      string = {
                        id = "cachix-auth-token";
                        description = "srid.cachix.org auth token";
                        secret = cascJson "value" (cascReadFile config.age.secrets.srid-cachix-auth-token.path);
                      };
                    }
                  ];
                }
              ];
            };
            jenkins = {
              numExecutors = 6;
              securityRealm = {
                local = {
                  allowsSignup = false;
                };
              };
            };
            unclassified.location.url = "https://${domain}/";
          };
        in
        builtins.toString (pkgs.writeText "jenkins.json" (builtins.toJSON cfg));
    };
    packages = with pkgs; [
      # Add packages used by Jenkins plugins here.
      git
      bash # 'sh' step requires this
      nix
      cachix
    ];
    # ./jenkins/update-plugins.sh
    plugins = import ./jenkins/plugins.nix {
      inherit (pkgs) fetchurl stdenv;
    };
    extraJavaOptions = [
      # Useful when the 'sh' step b0rks.
      # https://stackoverflow.com/a/66098536/55246
      "-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true"
    ];
  };

  # To allow the local node to run as builder, supporting nix builds.
  # This should not be necessary with external build agents.
  nix.settings.allowed-users = [ "jenkins" ];
  nix.settings.trusted-users = [ "jenkins" ];

  services.nginx = {
    virtualHosts.${domain} = {
      forceSSL = true;
      enableACME = true;
      locations."/".extraConfig = ''
        proxy_pass http://localhost:${toString port};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
