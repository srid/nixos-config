{
  outputs = { self, nixpkgs }: {
     nixosConfigurations.x1c7 = nixpkgs.lib.nixosSystem {
       system = "x86_64-linux";
       modules = [ ./configuration.nix ];
     };
  };
}