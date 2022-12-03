{ pkgs, flake, ... }: {
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };
  users.extraGroups.vboxusers.members = [ flake.config.people.myself ];
}
