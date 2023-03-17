{ pkgs, ... }:

# HOWTO:
# - Goto http://localhost:8080/
#
# TODO:
# - JCasC Nixified for configuration
# - Build agents (SSH slave)
#    - macOS slave
# - Github integration
#   https://github.com/jenkinsci/github-branch-source-plugin/blob/master/docs/github-app.adoc#configuration-as-code-plugin
let
  port = 9091;
in
{
  services.jenkins = {
    enable = true;
    inherit port;
    packages = with pkgs; [
      # Add packages used by Jenkins plugins here.
      nix
      git
      bash # 'sh' step requires this
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
    virtualHosts."jenkins.srid.ca" = {
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
