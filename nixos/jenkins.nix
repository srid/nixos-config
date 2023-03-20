{ pkgs, config, ... }:

# TODO:
# - Build agents (SSH slave)
#    - NixOS slave: container separation?
#    - macOS slave (later)
let
  # The port to run Jenkins on.
  port = 9091;
  # The domain in which Jenkins is exposed to the outside world through nginx.
  domain = "jenkins.srid.ca";

  # Config for configuration-as-code-plugin
  #
  # This enable us to configure Jenkins declaratively rather than fiddle with
  # the UI manually.
  # cf:
  # https://github.com/mjuh/nixos-jenkins/blob/master/nixos/modules/services/continuous-integration/jenkins/jenkins.nix
  cascConfig = {
    credentials = {
      system.domainCredentials = [
        {
          credentials = [
            {
              basicSSHUserPrivateKey = {
                id = "ssh-privkey";
                username = "jenkins";
                privateKeySource.directEntry.privateKey =
                  casc.readFile config.age.secrets.jenkins-ssh-privkey.path;
              };
            }
            {
              # Instructions for creating this Github App are at:
              # https://github.com/jenkinsci/github-branch-source-plugin/blob/master/docs/github-app.adoc#configuration-as-code-plugin
              githubApp = {
                appID = "307056"; # https://github.com/apps/jenkins-srid
                description = "Github App - jenkins-srid";
                id = "github-app";
                privateKey = casc.readFile config.age.secrets.jenkins-github-app-privkey.path;
              };
            }
            {
              string = {
                id = "cachix-auth-token";
                description = "srid.cachix.org auth token";
                secret = casc.json "value" (casc.readFile config.age.secrets.srid-cachix-auth-token.path);
              };
            }
            {
              string = {
                id = "docker-pass";
                description = "sridca Docker password";
                secret = casc.json "value" (casc.readFile config.age.secrets.srid-docker-pass.path);
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
      /*
      nodes = [
        {
          permanent = {
            name = "jenkins-agent-contaiiner";
            remoteFS = "/var/lib/jenkins/";
            launcher.ssh = {
              host = "undefined";
              port = 22;
            };
          };
        }
      ];
      */
    };
    unclassified.location.url = "https://${domain}/";
  };

  # Functions for working with configuration-as-code-plugin syntax.
  # https://github.com/jenkinsci/configuration-as-code-plugin/blob/master/docs/features/secrets.adoc#additional-variable-substitution
  casc = {
    readFile = path:
      "$" + "{readFile:" + path + "}";
    json = k: x:
      "$" + "{json:" + k + ":" + x + "}";
  };
in
{
  imports = [
    ./docker.nix
  ];
  services.jenkins.extraGroups = [ "docker" ];

  age.secrets.jenkins-ssh-privkey = {
    owner = "jenkins";
    file = ../secrets/jenkins-ssh-privkey.age;
  };
  age.secrets.jenkins-github-app-privkey = {
    owner = "jenkins";
    file = ../secrets/jenkins-github-app-privkey.age;
  };
  age.secrets.srid-cachix-auth-token = {
    owner = "jenkins";
    file = ../secrets/srid-cachix-auth-token.age;
  };
  age.secrets.srid-docker-pass = {
    owner = "jenkins";
    file = ../secrets/srid-docker-pass.age;
  };

  services.jenkins = {
    enable = true;
    inherit port;
    environment = {
      CASC_JENKINS_CONFIG =
        builtins.toString (pkgs.writeText "jenkins.json" (builtins.toJSON cascConfig));
    };
    packages = with pkgs; [
      # Add packages used by Jenkins plugins here.
      git
      bash # 'sh' step requires this
      coreutils
      which
      nix
      cachix
      docker
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
