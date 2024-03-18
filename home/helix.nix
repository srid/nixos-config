{
  programs.helix = {
    enable = true;
    settings = {
      theme = "snazzy";
      editor .true-color = true;
      keys.insert.j.j = "normal_mode";
      keys.insert.s.s = ":write"; # TODO: this should also put back in normal_mode
      keys.normal.s.s = ":write";
    };
  };
}
