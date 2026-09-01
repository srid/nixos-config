{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  packages = self + /packages;
in
self: super:

# Auto-import all packages from the packages directory
super.lib.mapAttrs'
  (name: _: super.lib.nameValuePair
    (super.lib.removeSuffix ".nix" name)
    (self.callPackage (packages + "/${name}") { }))
  (builtins.readDir packages)
