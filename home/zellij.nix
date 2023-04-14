{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      theme = if pkgs.system == "aarch64-darwin" then "dracula" else "default";
      # https://github.com/nix-community/home-manager/issues/3854
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
    };
  };

  home.packages = [
    # Open zellij by prompting for CWD
    (pkgs.nuenv.mkScript {
      name = "zux";
      script = ''
        let PRJ = (zoxide query -i)
        let NAME = ($PRJ | parse $"($env.HOME)/{relPath}" | get relPath | first | str replace -a / ／)
        echo $"Launching zellij for ($PRJ)"
        cd $PRJ ; exec zellij attach -c $NAME
      '';
    })
  ];
}
