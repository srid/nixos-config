{ pkgs, ... }: {
  virtualisation.lxd.enable = true;

  virtualisation.docker.enable = true;

  users.users.srid = {
    extraGroups = [ "lxd" "docker" ];
  };
}
