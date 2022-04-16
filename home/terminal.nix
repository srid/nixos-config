{ pkgs, ... }:
{
  # Key packages required on nixos and macos
  home.packages = with pkgs; [
    # Unixy tools
    gnumake
    ripgrep
    htop

    # Haskell dev
    ghcid
  ];

  programs = {
    bat.enable = true;
    autojump.enable = false;
    zoxide.enable = true;
    fzf.enable = true;
    jq.enable = true;

    # Better terminal, with good rendering.
    kitty = {
      enable = true;
      # Pick "name" from https://github.com/kovidgoyal/kitty-themes/blob/master/themes.json
      theme = "Tokyo Night";
      font = {
        name = "Monaco";
        size = 14;
      };
    };
  };
}
