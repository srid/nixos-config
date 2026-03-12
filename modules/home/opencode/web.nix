{ config, lib, pkgs, ... }:

{
  programs.opencode.web = {
    enable = true;
    # Bind to Tailscale IP only
    extraArgs = [ "--hostname" "100.122.32.106" "--port" "4096" ];
  };
}
