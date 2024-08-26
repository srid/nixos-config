{ flake, system, ... }:

self: super: {
  fuckport = self.callPackage ./fuckport.nix { };
  twitter-convert = self.callPackage ./twitter-convert { };
  sshuttle-via = self.callPackage ./sshuttle-via.nix { };
  ci = self.callPackage ./ci { };
  touchpr = self.callPackage ./touchpr { };
  # nix-health = flake.inputs.nix-browser.packages.${system}.nix-health;
  actualism-app = flake.inputs.actualism-app.packages.${system}.default;
  omnix = flake.inputs.omnix.packages.${system}.default;
  git-merge-and-delete = self.callPackage ./git-merge-and-delete.nix { };
}
