{ pkgs, ... }:
{
  shellAliases = {
    e = "nvim";
    g = "${pkgs.git}/bin/git";
    lg = "${pkgs.lazygit}/bin/lazygit";
    l = "${pkgs.exa}/bin/exa";
    ll = "${pkgs.exa}/bin/exa -l";
    ls = "l";
    pux = "sh -c \"tmux -S $(pwd).tmux attach\"";
    pux-iterm = "sh -c \"tmux -S $(pwd).tmux -CC attach\"";
  };
}
