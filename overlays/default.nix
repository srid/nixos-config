{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  packages = self + /packages;

in
self: super:
let
  # Auto-import all packages from the packages directory
  # TODO: Upstream this to nixos0-unified?
  entries = builtins.readDir packages;

  # Convert directory entries to package definitions
  makePackage = name: type:
    let
      # Remove .nix extension for package name
      pkgName =
        if type == "regular" && builtins.match ".*\\.nix$" name != null
        then builtins.replaceStrings [ ".nix" ] [ "" ] name
        else name;
    in
    {
      name = pkgName;
      value = self.callPackage (packages + "/${name}") { };
    };

  # Import everything in packages directory
  packageOverlays = builtins.listToAttrs
    (builtins.attrValues (builtins.mapAttrs makePackage entries));

in
packageOverlays
