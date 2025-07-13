{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    inputs.github-nix-ci.nixosModules.default
  ];

  nix.gc = {
    automatic = true;
  };

  services.github-nix-ci = {
    age.secretsDir = self + /secrets;
    runnerSettings = {
      extraPackages = with pkgs; [
        omnix
        just
        sd
        nushell # https://github.com/marketplace/actions/setup-nu
      ];
    };

    # Don't forget to add these repos here:
    # https://github.com/settings/personal-access-tokens/3513625
    personalRunners = {
      "srid/nixos-config".num = 1;
      "srid/emanote".num = 2;
      "srid/haskell-flake".num = 1;
      "srid/nixos-unified".num = 1;
    };
  };
}
