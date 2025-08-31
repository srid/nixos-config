{ pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    # openFirewall = true;
  };
  environment.systemPackages = with pkgs; [
    yt-dlp
    ffmpeg
    aria2
    tmux
    vlc
  ];

  # A separate user to manage the library filesystem.
  users.users.jellyfin-manager = {
    isNormalUser = true;
    group = "jellyfin";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "pureintent" = {
        locations = {
          # Jellyfin
          "/" = {
            proxyPass = "http://localhost:8096";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
