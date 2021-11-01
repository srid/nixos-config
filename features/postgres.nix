{ pkgs, ... }:
{
  # PostgreSQL itself
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_12; # HACK: for work
    # enableTCPIP = false;
    # https://nixos.wiki/wiki/PostgreSQL
    authentication = pkgs.lib.mkOverride 10
      ''
        # Unix domain socket
        local all all trust
        # TCP/IP connections from loopback only
        host all all ::1/128 trust
      '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE nixcloud WITH LOGIN PASSWORD 'nixcloud' CREATEDB;
      CREATE DATABASE nixcloud;
      GRANT ALL PRIVILEGES ON DATABASE nixcloud TO nixcloud;
    '';
  };
}
