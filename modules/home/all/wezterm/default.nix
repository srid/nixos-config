{
  programs.wezterm = {
    enable = true;
    # https://alexplescan.com/posts/2024/08/10/wezterm/
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
