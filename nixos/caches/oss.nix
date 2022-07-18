{ pkgs, ... }: {
  nix.settings.trusted-public-keys = [
    # "srid.cachix.org-1:MTQ6ksbfz3LBMmjyPh0PLmos+1x+CdtJxA/J2W+PQxI="
    # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];
  nix.settings.substituters = [
    # "https://srid.cachix.org"
    # "https://nix-community.cachix.org"
    "https://cache.garnix.io"
  ];
}
