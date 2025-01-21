{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    apps.incus-image-import.program = pkgs.writeShellApplication {
      name = "incus-image-import";
      text = ''
        NAME=$1

        echo "Building image ... "
        METADATA=$(nix build --no-link --print-out-paths ${inputs.self}#nixosConfigurations."$NAME".config.system.build.metadata)/tarball/nixos*.tar.xz
        IMG=$(nix build --no-link --print-out-paths ${inputs.self}#nixosConfigurations."$NAME".config.system.build.qemuImage)/nixos.qcow2

        echo "Importing ... "
        set -x
        sudo incus image import --alias srid/"$NAME" "$METADATA" "$IMG"
      '';
    };
  };
}
