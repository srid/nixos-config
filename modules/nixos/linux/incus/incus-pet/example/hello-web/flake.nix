# hello-web — minimal incus-pet example.
#
# Self-contained reference flake that ships the three outputs incus-pet
# consumes:
#
#   - packages.<sys>.default      a tiny static-file server (darkhttpd
#                                 wrapped to read HOST/PORT from env)
#   - nixosModules.default        services.hello-web.{enable, package,
#                                 host, port}  +  a systemd unit
#   - nixosModules.incus          the deploy contract — wires the
#                                 service to bind 8080 inside an incus
#                                 container at hostname "hello-web"
#
# Deploy with (from a host that has the incus daemon + incus-pet CLI):
#
#   nix run github:srid/nixos-config#incus-pet -- \
#     deploy <path-to-this-flake> --port 8081 --listen <ip>
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      eachSystem = f: nixpkgs.lib.genAttrs systems
        (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = eachSystem (pkgs:
        let
          www = pkgs.writeTextDir "index.html" ''
            <!doctype html>
            <meta charset="utf-8">
            <title>hello-web</title>
            <h1>Hello from incus-pet</h1>
            <p>Served by darkhttpd inside an incus container.</p>
          '';
          hello-web = pkgs.writeShellApplication {
            name = "hello-web";
            runtimeInputs = [ pkgs.darkhttpd ];
            text = ''
              HOST="''${HOST:-0.0.0.0}"
              PORT="''${PORT:-8080}"
              exec darkhttpd ${www} --addr "$HOST" --port "$PORT"
            '';
            meta.mainProgram = "hello-web";
          };
        in
        {
          default = hello-web;
          hello-web = hello-web;
        });

      nixosModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.services.hello-web;
        in
        {
          options.services.hello-web = {
            enable = lib.mkEnableOption "hello-web example server";
            package = lib.mkOption {
              type = lib.types.package;
              description = "The hello-web package to run (must expose bin/hello-web via meta.mainProgram).";
            };
            host = lib.mkOption {
              type = lib.types.str;
              default = "0.0.0.0";
              description = "Address the HTTP server binds to.";
            };
            port = lib.mkOption {
              type = lib.types.port;
              default = 8080;
              description = "Port the HTTP server listens on.";
            };
          };

          config = lib.mkIf cfg.enable {
            systemd.services.hello-web = {
              description = "hello-web example HTTP server";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              environment = {
                HOST = cfg.host;
                PORT = toString cfg.port;
              };
              serviceConfig = {
                ExecStart = lib.getExe cfg.package;
                Restart = "on-failure";
                RestartSec = 2;
                DynamicUser = true;
              };
            };
          };
        };

      # incus-pet contract — see SKILL.md in the incus-pet tree.
      nixosModules.incus = { config, lib, pkgs, ... }: {
        imports = [ self.nixosModules.default ];

        incus.container = {
          enable = true;
          hostname = lib.mkDefault "hello-web";
        };
        system.stateVersion = "25.05";

        services.hello-web = {
          enable = true;
          package = lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.default;
          host = lib.mkDefault "0.0.0.0";
          port = 8080; # fixed by the incus-pet contract
        };
      };

      formatter = eachSystem (pkgs: pkgs.nixpkgs-fmt);
    };
}
