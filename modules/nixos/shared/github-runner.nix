{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    # See https://github.com/juspay/github-nix-ci
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
      "srid/ema".num = 2;
      "srid/t".num = 1;
      "srid/srid".num = 1;
      "srid/imako".num = 1;
      "srid/haskell-flake".num = 2;
      "srid/nixos-unified".num = 2;
    };

    orgRunners = {
      "emaletter".num = 2;
    };
  };
}
