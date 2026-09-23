{ pkgs, lib, ... }:
{
  environment.systemPackages = [ pkgs.haruna ];

  home-manager.sharedModules = [
    {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = lib.genAttrs [
          "video/mp4"
          "video/webm"
          "video/x-matroska"
          "video/quicktime"
          "video/x-msvideo"
          "video/vnd.avi"
          "video/x-ms-wmv"
          "video/mp2t"
          "video/mpeg"
          "video/ogg"
        ] (_: [ "org.kde.haruna.desktop" ]);
      };
    }
  ];
}
