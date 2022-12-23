{ pkgs, ... }: {
  nix.settings.trusted-public-keys = [
    (builtins.readFile ../../secrets/cache-pub-key)
    # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];
  nix.settings.substituters = [
    "https://cache.srid.ca"
    # "https://nix-community.cachix.org"
    # "https://cache.garnix.io"
  ];
}
