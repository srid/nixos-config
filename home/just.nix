{ pkgs, ... }:
{
  programs.bash = {
    # https://just.systems/man/en/chapter_63.html
    # FIXME: doesn't work (macos)
    initExtra = ''
      # complete -F _just -o bashdefault -o default j
    '';
  };

  home.shellAliases.j = "just";
  home.packages = with pkgs; [ just ];
}
