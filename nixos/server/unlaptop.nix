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
  # Uncomment this if leaving the laptop with lid closed at all times 
  # (currently I don't; I want lid close to suspend it)
  # services.logind.lidSwitch = "ignore";
}
