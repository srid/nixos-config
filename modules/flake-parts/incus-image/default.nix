{ inputs, ... }: {
  perSystem = { pkgs, system, ... }: {
    apps = {
      incus-image-vm-import.program = pkgs.writeShellApplication {
        name = "incus-image-vm-import";
        text = ''
          NAME=$1

          echo "Building image ... "
          METADATA=$(nix build --no-link --print-out-paths ${inputs.self}#nixosConfigurations."$NAME".config.system.build.metadata)/tarball/
          IMG=$(nix build --no-link --print-out-paths ${inputs.self}#nixosConfigurations."$NAME".config.system.build.qemuImage)/nixos.qcow2

          echo "Importing ... "
          set -x
          sudo incus image import --alias srid/"$NAME" "$METADATA"/*.tar.xz "$IMG"
        '';
      };

      incus-image-container-import.program = pkgs.writeShellApplication {
        name = "incus-image-container-import";
        text = ''
          NAME=$1

          echo "Building image ... "
          METADATA=$(nix build --no-link --print-out-paths ${inputs.self}#nixosConfigurations."$NAME".config.system.build.metadata)/tarball/
          IMG=$(nix build --no-link --print-out-paths ${inputs.self}#nixosConfigurations."$NAME".config.system.build.squashfs)/nixos-lxc-image-${system}.squashfs

          echo "Importing ... "
          set -x
          sudo incus image import --alias srid/"$NAME" "$METADATA"/*.tar.xz "$IMG"
        '';
      };
    };
  };
}
