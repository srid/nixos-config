 
{ config, pkgs, ... }:

{
  # NOTE: might have to disable tlp to ignore suspend on lid. Ideally
  # disable just that. P71 is acting as a server right now, always plugged.
  services.tlp = {
    enable = true;
    settings = {
      SCHED_POWERSAVE_ON_AC = 1;
    };
  };
  # This machine is now a long-running home-server with a bluetooth keyboard
  services.logind.lidSwitch = "ignore";
}
