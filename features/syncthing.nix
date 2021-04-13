{ pkgs, ... }: {
  services = {
    syncthing = {
      enable = true;
      user = "srid";
      dataDir = "/home/srid";
      # We want nodes in the same network to be able to connect directly to one
      # another, without having to go through a third-party relay. So open
      # firewall ports.
      openDefaultPorts = true;
    };
  };
}
