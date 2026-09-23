{ flake, ... }:
{
  services.flatpak.enable = true;

  home-manager.sharedModules = [
    flake.inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ({ config, ... }: {
      services.flatpak = {
        enable = true;
        remotes = [
          {
            name = "flathub";
            location = "https://flathub.org/repo/flathub.flatpakrepo";
          }
          {
            name = "GeForceNOW";
            location = "https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo";
          }
        ];
        packages = [
          { appId = "com.nvidia.geforcenow"; origin = "GeForceNOW"; }
        ];
      };

      # Use NVIDIA's exported launcher rather than maintaining our own copy.
      # This also exposes it to sessions started before Flatpak was enabled.
      xdg.dataFile."applications/com.nvidia.geforcenow.desktop".source =
        config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/.local/share/flatpak/exports/share/applications/com.nvidia.geforcenow.desktop";
    })
  ];
}
