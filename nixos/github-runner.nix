{
  services.github-nix-ci = {
    age.secretsDir = ../secrets;
    personalRunners = {
      "srid/nixos-config".num = 2;
    };
  };
}
