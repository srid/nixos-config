{ lib, ... }:
let
  shellAliases = {
    e = "nvim";
    ee = ''
      fzf --bind "enter:execute(nvim {})"
    '';
    g = "git";
    lg = "lazygit";
  };
in
{
  programs.bash = { inherit shellAliases; };
  programs.zsh = { inherit shellAliases; };
  programs.nushell.extraConfig =
    lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "alias ${k} = ${v} ") shellAliases);
}

