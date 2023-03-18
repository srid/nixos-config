{ pkgs, ... }:

# HOWTO:
# - Goto http://localhost:8080/
#
# TODO:
# - Github integration
#   https://github.com/jenkinsci/github-branch-source-plugin/blob/master/docs/github-app.adoc#configuration-as-code-plugin
# - Build agents (SSH slave)
#    - macOS slave
let
  port = 9091;
  domain = "jenkins.srid.ca";
in
{
  services.jenkins = {
    enable = true;
    inherit port;
    environment = {
      CASC_JENKINS_CONFIG =
        let
          # Template:
          # https://github.com/mjuh/nixos-jenkins/blob/master/nixos/modules/services/continuous-integration/jenkins/jenkins.nix
          cfg = {
            credentials = {
              system.domainCredentials = [
                {
                  credentials = [
                    {
                      githubApp = {
                        appID = "307056"; # https://github.com/apps/jenkins-srid
                        description = "Github App";
                        id = "github-app";
                        # FIXME! https://github.com/ryantm/agenix#builtinsreadfile-anti-pattern
                        privateKey = builtins.readFile ./jenkins/github-app.pem;
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
          };
        in
        builtins.toString (pkgs.writeText "jenkins.yml" (builtins.toJSON cfg));
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
