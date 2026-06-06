{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.drishti.homeManagerModules.default
  ];

  # Generic enabler. The host list is machine-specific (zest watches the
  # tailnet boxes; pureintent watches its pu-managed CI fleet), so each
  # consuming config sets `services.drishti.hosts`.
  services.drishti = {
    enable = true;
    package = inputs.drishti.packages.${pkgs.stdenv.hostPlatform.system}.default;
    port = 7720;
  };
}
