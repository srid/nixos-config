{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  packages = self + /packages;
in
self: super: {
  nuenv = (inputs.nuenv.overlays.nuenv self super).nuenv;
  fuckport = self.callPackage "${packages}/fuckport.nix" { };
  sshuttle-via = self.callPackage "${packages}/sshuttle-via.nix" { };
  ci = self.callPackage "${packages}/ci" { };
  touchpr = self.callPackage "${packages}/touchpr" { };
  # omnix = inputs.omnix.packages.${self.system}.default;
  git-merge-and-delete = self.callPackage "${packages}/git-merge-and-delete.nix" { };
}
