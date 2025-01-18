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
    personalRunners = {
      "srid/nixos-config".num = 1;
    };
  };
}
