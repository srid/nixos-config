# Juspay-specific configuration using the work jump host module


{ flake, ... }:
let
  inherit (flake.inputs) jumphost-nix;
  homeMod = flake.inputs.self + /modules/home;
in
{
  imports = [
    "${jumphost-nix}/module.nix"
    "${homeMod}/agenix.nix"
    # "${homeMod}/claude-code/juspay.nix"  # Disabled: not using Claude Code at Juspay
  ];

  programs.jumphost = {
    enable = true;
    host = "srid@vanjaram.tail12b27.ts.net";

    sshHosts = {
      "ssh.bitbucket.juspay.net".user = "git";
    };

    git = {
      baseCodeDir = "~/juspay";
      email = "sridhar.ratnakumar@juspay.in";
    };

    socks5Proxy = {
      enable = true;
    };
  };

  home.shellAliases = {
    jcurl = "curl --socks5 localhost:1080";
  };
}
