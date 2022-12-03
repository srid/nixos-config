{ pkgs, flake, ... }: {
  virtualisation.lxd.enable = true;

  users.users.${flake.config.people.myself} = {
    extraGroups = [ "lxd" ];
  };
}
