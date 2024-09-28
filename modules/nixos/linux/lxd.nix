{ flake, ... }: {
  virtualisation.lxd.enable = true;

  users.users.${flake.config.me.username} = {
    extraGroups = [ "lxd" ];
  };
}
