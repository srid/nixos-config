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
    zellij
  ];

  /* Not using this
    services.transmission = {
    enable = true;
    group = "jellyfin";
    openRPCPort = true;
    settings = {
      rpc-bind-address = "localhost";
      rpc-whitelist-enabled = false; # ACL managed through Tailscale
      rpc-host-whitelist = "pureintent pureintent.rooster-blues.ts.net";
      download-dir = "/Self/Downloads";
      trash-original-torrent-files = true;
    };
    };
  */

  /* Disabled, because jellyfin has issues
    age.secrets = {
    "pureintent-basic-auth.age" = {
      file = self + /secrets/pureintent-basic-auth.age;
      owner = "nginx";
    };
    };
    services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # virtualHosts."pureintent.rooster-blues.ts.net" = {
    virtualHosts = rec {
      "pureintent.rooster-blues.ts.net" = pureintent;
      "pureintent" = {
        locations = {
          # Return index.html with likns to other two sites
          "/" = {
            extraConfig = ''
              default_type text/html;
            '';
            return = "200 '<ul style=\"font-size: 4em;\"><li><a href=\"/web\">Jellyfin</a> (Watch Movies)</li><li><a href=\"/transmission\">Transmission</a> (Torrent Download)</li></ul>'";
          };
          # Transmission
          "/transmission" = {
            proxyPass = "http://localhost:9091/transmission";
            proxyWebsockets = true;
            # transmission has no login page, so use basic auth
            basicAuthFile = config.age.secrets."pureintent-basic-auth.age".path;
          };
          # Jellyfin
          "/web" = {
            proxyPass = "http://localhost:8096";
            proxyWebsockets = true;
          };
        };
      };
    };
    };
  */
}
