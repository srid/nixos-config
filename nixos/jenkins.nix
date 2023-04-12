{ flake, config, ... }:

{
  imports = [
    flake.inputs.jenkins-nix-ci.nixosModules.default # Provided by https://github.com/juspay/jenkins-nix-ci
  ];

  jenkins-nix-ci = {
    domain = "jenkins.srid.ca";
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

  services.nginx = {
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
