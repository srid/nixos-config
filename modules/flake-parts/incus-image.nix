{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    apps.incus-image-import.program = pkgs.writeShellApplication {
      name = "incus-image-import";
      text = ''
        NAME=$1
        METADATA=$(nix build --no-link --print-out-paths ${inputs.self}#nixosConfigurations."$NAME".config.system.build.metadata)
        IMG=$(nix build --no-link --print-out-paths ${inputs.self}#nixosConfigurations."$NAME".config.system.build.qemuImage)/nixos.qcow2
        incus image import --alias srid/"$NAME" "$METADATA" "$IMG"
      '';
    };
  };
}
