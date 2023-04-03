{ pkgs, ... }:
let
  # These aliases should work on all shells.
  shellAliasesSimple = {
    e = "nvim";
    g = "${pkgs.git}/bin/git";
    lg = "lazygit";
  };
  # These aliases should work on bash/zsh.
  shellAliases = shellAliasesSimple // {
    ee = "nvim \"$(fzf)\"";
    ls = "${pkgs.exa}/bin/exa";
    l = "ls";
    ll = "ls -l";
    lt = "ls --tree";
    # Project tmux. 
    pux = "sh -c \"tmux -S $(pwd).tmux attach\"";
  };
in
{
  programs.bash = { inherit shellAliases; };
  programs.zsh = { inherit shellAliases; };
}
