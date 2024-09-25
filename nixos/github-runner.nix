{
  services.github-nix-ci = {
    age.secretsDir = ../secrets;
    personalRunners = {
      "srid/srid".num = 1;
    };
  };
}
