{ flake, system, ... }:
{
  actualism-app = {
    port = 3000; # TODO: Change this, and pass to daemon (renaming `package` to `exec` or something)
    domain = "actualism.app";
    package = flake.inputs.actualism-app.packages.${system}.default;
  };
}
