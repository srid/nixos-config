self: super: {
  fuckport = self.callPackage ./fuckport.nix { };
  mood = self.callPackage ./mood.nix { };
}
