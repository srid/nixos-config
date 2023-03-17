{ pkgs, ... }:

# HOWTO:
# - Goto http://localhost:8080/
let
  port = 9091;
in
{
  services.jenkins = {
    enable = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      # Add packages used by Jenkins plugins here.
      nix
      git
      bash # 'sh' step requires this
    ];
    inherit port;
    withCLI = true;
    # nix run github:Fuuzetsu/jenkinsPlugins2nix -- -p github-api -p git -p workflow-aggregator -p ssh-slaves   > ./jenkins/plugins.nix
    plugins = import ./jenkins/plugins.nix {
      inherit (pkgs) fetchurl stdenv;
    };
    extraJavaOptions = [
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
