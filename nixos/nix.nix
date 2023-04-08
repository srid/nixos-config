{ flake, ... }:

{
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    flake.inputs.nuenv.overlays.nuenv

    # https://github.com/starship/starship/issues/5063
    (self: super: {
      starship = super.starship.overrideDerivation (oa: {
        patches = (oa.patches or [ ]) ++ [
          (builtins.fetchurl {
            name = "nushell.patch";
            url = "https://github.com/starship/starship/commit/041a51835371d3738cc7b597b4a506a5dc4341c9.diff";
            sha256 = "sha256:0az1jjb24mngzybgv7kavdj1bhfdm0cqnci3gz6zkgpaxqvw7vnz";
          })
        ];
      });
    })
  ];
}

