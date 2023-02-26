{ pkgs, config, flake, ... }: {
  virtualisation.docker.enable = true;

  users.users.${flake.config.people.myself} = {
    extraGroups = [ "docker" ];
  };
}
