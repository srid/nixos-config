{ flake, config, pkgs, ... }:

{
  imports = [
    flake.inputs.jenkins-nix-ci.nixosModules.default # Provided by https://github.com/juspay/jenkins-nix-ci
  ];

  jenkins-nix-ci = {
    domain = "jenkins.srid.ca";
    nodes = {
      containerSlaves = {
        externalInterface = "eth0";
        hostAddress = "167.235.115.189";
        containers = {
          jenkins-slave-nixos-1.hostIP = "192.168.100.11";
          jenkins-slave-nixos-2.hostIP = "192.168.100.12";
        };
      };
      sshSlaves.biryani = {
        hostIP = "100.97.32.60"; # Tailscale IP
        numExecutors = 4;
        labelString = "macos aarch64-darwin x86_64-darwin";
      };
    };
    plugins = [
      "github-api"
      "git"
      "github-branch-source"
      "workflow-aggregator"
      "ssh-slaves"
      "configuration-as-code"
      "pipeline-graph-view"
      "pipeline-utility-steps"
    ];
    plugins-file = "nixos/jenkins/plugins.nix";

    features = {
      cachix.enable = true;
      docker.enable = true;
      githubApp.enable = true;
      nix.enable = true;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "srid@srid.ca";
  };
  # Allow 80 during acme renewal
  networking.firewall.allowedTCPPorts = [ 443 ];
  services.nginx = {
    enable = true;
    virtualHosts.${config.jenkins-nix-ci.domain} = {
      forceSSL = true;
      enableACME = true;
      locations."/".extraConfig = ''
        proxy_pass http://localhost:${toString config.jenkins-nix-ci.port};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
