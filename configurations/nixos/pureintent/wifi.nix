# Wi-Fi for pureintent, declared rather than imperative.
#
# The PSK lives in an agenix secret and is substituted into the keyfile by
# `NetworkManager-ensure-profiles` (environmentFiles -> envsubst), so nothing
# secret lands in the repo or the Nix store. `autoconnect = true` means a boot
# with no Ethernet associates on its own — no fallback timer, no manual
# `nmcli connection up`, no dependence on a login. Route metric 600 and
# autoconnect-priority 0 keep Ethernet (metric 100) preferred when both links
# are up.
{ config, ... }:
{
  age.secrets.wifi-psk.file = ../../../secrets/wifi-psk.env.age;

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.age.secrets."wifi-psk".path ];
    profiles."www.simpleactualism.com" = {
      connection = {
        id = "www.simpleactualism.com";
        type = "wifi";
        interface-name = "wlp2s0";
        autoconnect = true;
        autoconnect-priority = 0;
      };
      wifi = {
        ssid = "www.simpleactualism.com";
        mode = "infrastructure";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "\${WIFI_PSK}";
      };
      ipv4 = {
        method = "auto";
        route-metric = 600;
      };
      ipv6 = {
        method = "auto";
        route-metric = 600;
      };
    };
  };
}
