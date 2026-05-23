# Expose the incus-pet CLI as a flake package.
#
# The CLI itself lives under modules/nixos/linux/incus/incus-pet/ so the
# whole incus/ tree stays a self-contained transplant unit (when it
# eventually lifts to its own repo, this flake-parts wiring stays
# behind).
{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages.incus-pet = pkgs.callPackage
      ../nixos/linux/incus/incus-pet
      { };
  };
}
