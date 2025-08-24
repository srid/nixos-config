{ pkgs, ... }:
{
  home.shellAliases.j = "just";
  home.packages = with pkgs; [ just ];
}
