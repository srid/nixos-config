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

  users.extraUsers.jellyfin = {
    # isSystemUser = true;
    group = "jellyfin";
    extraGroups = [ "video" "render" ];
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa # Ensure mesa drivers are available
      # AMDVLK is for Vulkan, but is good practice for AMD graphics
      amdvlk
      # Optional: for monitoring GPU usage
      # amd-gpu-top
    ];
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
