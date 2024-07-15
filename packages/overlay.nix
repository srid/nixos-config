{ flake, system, ... }:

self: super: {
  fuckport = self.callPackage ./fuckport.nix { };
  twitter-convert = self.callPackage ./twitter-convert { };
  sshuttle-via = self.callPackage ./sshuttle-via.nix { };
  nixci-build-remote = self.callPackage (import ./nixci-build-remote.nix { inherit (flake) inputs; }) { };
  ci = self.callPackage ./ci { };
  nixci = flake.inputs.nixci.packages.${system}.default;
  # nix-health = flake.inputs.nix-browser.packages.${system}.nix-health;
  actualism-app = flake.inputs.actualism-app.packages.${system}.default;
}
