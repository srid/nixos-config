{ pkgs, lib, ... }:

# https://github.com/dandavison/delta#get-started
# https://dandavison.github.io/delta/configuration.html
{
  programs.git.extraConfig = {
    core.pager = lib.getExe pkgs.delta;
    interactive.diffFilter = "${lib.getExe pkgs.delta} --color-only --features=interactive";
    delta = {
      features = "decorations";
      navigate = true;
      light = false;
      side-by-side = true;
    };
    merge.conflictstyle = "diff3";
    diff.colorMoved = "default";
  };
}
