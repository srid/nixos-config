{ lib, ... }:
let
  shellAliases = {
    e = "nvim";
    ee = ''
      nvim (fzf)
    '';
    g = "git";
    lg = "lazygit";
  };
in
{
  programs.bash = { inherit shellAliases; };
  programs.zsh = { inherit shellAliases; };
  # Until https://github.com/nix-community/home-manager/pull/3529
  programs.nushell.extraConfig =
    lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "alias ${k} = ${v} ") shellAliases);
}

