{ flake, system, ... }:

# By convention, ports 15000 and above are used for webapps
{
  actualism-app = rec {
    port = 15001;
    domain = "actualism.app";
    package = flake.inputs.actualism-app.packages.${system}.default;
    exec = "${package}/bin/actualism-app ${builtins.toString port}";
  };
}
