{ pkgs, ... }:
let
  postgrest = pkgs.haskellPackages.postgrest;
in
{
  # PostgreSQL itself
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    enableTCPIP = false;
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

  # PostgREST as systemd service
  systemd.services.postgrest = {
    enable = true;
    description = "PostgREST daemon";
    after = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart =
        let
          pgrstConf = pkgs.writeText "pgrst.conf" ''
            db-uri = "postgres://postgres@localhost/postgres"
            db-schema = "chronicle"
            # TODO: change when going production
            db-anon-role = "postgres"
            server-port = 7000
          '';
        in
        "${postgrest}/bin/postgrest ${pgrstConf}";
      Restart = "always";
    };
  };
}
