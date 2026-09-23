let
  laptop = {
    criteria = "eDP-1";
    status = "enable";
    mode = "3200x2000@120Hz";
    scale = 1.55;
    position = "0,0";
  };
  studio = {
    criteria = "Apple Computer Inc StudioDisplay 0x361CF30E";
    status = "enable";
    mode = "5120x2880@60Hz";
    scale = 2.25;
    position = "0,0";
  };
  dockedLaptop = {
    inherit (laptop) criteria;
    status = "disable";
  };
in
{
  home-manager.sharedModules = [
    {
      services.kanshi = {
        enable = true;
        systemdTarget = "niri.service";
        # First matching profile wins. Disable the spare MST tile only when the
        # real Studio Display is present, leaving other DP-2 monitors usable.
        settings = [
          {
            profile = {
              name = "studio-with-mst";
              outputs = [
                studio
                dockedLaptop
                {
                  criteria = "DP-2";
                  status = "disable";
                }
              ];
            };
          }
          {
            profile = {
              name = "studio";
              outputs = [
                studio
                dockedLaptop
              ];
            };
          }
          {
            profile = {
              name = "laptop";
              outputs = [ laptop ];
            };
          }
        ];
      };
    }
  ];
}
