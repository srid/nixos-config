{
  programs.helix = {
    enable = true;
    settings = {
      theme = "snazzy";
      editor .true-color = true;
      keys.insert.j.j = "normal_mode";
      # Shortcut to save file, in any mode.
      keys.insert."C-s" = [":write" "normal_mode"];
      keys.normal."C-s" = ":write";
    };
  };
}
