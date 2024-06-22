{ config, ... }:

{
  age.secrets."github-nix-ci/srid.token.age" = {
    inherit (config.services.github-nix-ci.output.runner) owner;
    file = ../secrets/github-nix-ci/srid.token.age;
  };
  services.github-nix-ci = {
    personalRunners = {
      "srid/nixos-config".num = 1;
    };
  };
}
