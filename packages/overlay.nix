{ flake, system, ... }:

self: super: {
  fuckport = self.callPackage ./fuckport.nix { };
  twitter-convert = self.callPackage ./twitter-convert { };
  sshuttle-via = self.callPackage ./sshuttle-via.nix { };
  nixci = flake.inputs.nixci.packages.${system}.default;
  # nix-health = flake.inputs.nix-browser.packages.${system}.nix-health;
  actualism-app = flake.inputs.actualism-app.packages.${system}.default;

  # Use just v1.27.0, until upstream upgrades it.
  just = super.just.overrideAttrs (oa: rec {
    name = "${oa.pname}-${version}";
    version = "1.27.0";
    src = super.fetchFromGitHub {
      owner = "casey";
      repo = oa.pname;
      rev = "refs/tags/${version}";
      hash = "sha256-xyiIAw8PGMgYPtnnzSExcOgwG64HqC9TbBMTKQVG97k=";
    };
    # Overriding `cargoHash` has no effect; we must override the resultant
    # `cargoDeps` and set the hash in its `outputHash` attribute.
    cargoDeps = oa.cargoDeps.overrideAttrs (super.lib.const {
      name = "${name}-vendor.tar.gz";
      inherit src;
      outputHash = "sha256-jMurOCr9On+sudgCzIBrPHF+6jCE/6dj5E106cAL2qw=";
    });

    doCheck = false;
  });
}
