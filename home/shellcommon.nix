{ lib, ... }:
let
  shellAliases = {
    e = "nvim";
    ee = ''
      nvim (fzf)
    '';
    g = "git";
    lg = "lazygit";
    # TODO: Add 'l' alias, after https://www.nushell.sh/blog/2023-04-04-nushell_0_78.html#aliases-now-can-shadow
  };
in
{
  programs.bash = { inherit shellAliases; };
  programs.zsh = { inherit shellAliases; };
  # Until https://github.com/nix-community/home-manager/pull/3529
  programs.nushell.extraConfig =
    lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "alias ${k} = ${v} ") shellAliases);
}

