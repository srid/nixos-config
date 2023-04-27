{ pkgs, lib, ... }:

{
  home.shellAliases = {
    e = "nvim";
    g = "git";
    lg = "lazygit";
    l = lib.getExe pkgs.exa;
  };

  # Until https://github.com/nix-community/home-manager/pull/3529
  # programs.nushell.extraConfig =
  #  lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "alias ${k} = ${v} ") config.home.shellAliases);
}

