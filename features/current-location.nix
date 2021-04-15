{ config, pkgs, ... }:

{
  time.timeZone = "America/New_York";

  location = {
    # Quebec City
    latitude = 46.813359;
    longitude = -71.215796;
  };
}
