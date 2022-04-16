{ pkgs, ... }:
{
  shellAliases = {
    e = "nvim";
    g = "${pkgs.git}/bin/git";
    lg = "lazygit";
    ls = "${pkgs.exa}/bin/exa";
    l = "ls";
    ll = "ls -l";
    lt = "ls --tree";
    pux = "sh -c \"tmux -S $(pwd).tmux attach\"";
    pux-iterm = "sh -c \"tmux -S $(pwd).tmux -CC attach\"";
  };
}
