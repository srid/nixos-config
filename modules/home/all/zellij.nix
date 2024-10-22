{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      theme = if pkgs.system == "aarch64-darwin" then "dracula" else "gruvbox-light";
      # https://github.com/nix-community/home-manager/issues/3854
      # https://github.com/zellij-org/zellij/blob/main/zellij-utils/assets/themes/gruvbox.kdl
      themes.dracula = {
        fg = [ 248 248 242 ];
        bg = [ 40 42 54 ];
        black = [ 0 0 0 ];
        red = [ 255 85 85 ];
        green = [ 80 250 123 ];
        yellow = [ 241 250 140 ];
        blue = [ 98 114 164 ];
        magenta = [ 255 121 198 ];
        cyan = [ 139 233 253 ];
        white = [ 255 255 255 ];
        orange = [ 255 184 108 ];
      };
      themes.gruvbox-light = {
        fg = [ 124 111 100 ];
        bg = [ 251 82 75 ];
        black = [ 40 40 40 ];
        red = [ 205 75 69 ];
        green = [ 152 151 26 ];
        yellow = [ 215 153 33 ];
        blue = [ 69 133 136 ];
        magenta = [ 177 98 134 ];
        cyan = [ 104 157 106 ];
        white = [ 213 196 161 ];
        orange = [ 214 93 14 ];
      };
    };
  };
}
