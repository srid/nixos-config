{ pkgs, ... }: {
  virtualisation.lxd.enable = true;
  users.users.srid = {
    extraGroups = [ "lxd" ];
  };
}
