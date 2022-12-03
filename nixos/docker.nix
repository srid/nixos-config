{ pkgs, config, ... }: {
  virtualisation.docker.enable = true;

  users.users.${config.people.myself} = {
    extraGroups = [ "docker" ];
  };
}
