# Juspay-specific configuration using the work jump host module


{ config, flake, ... }:
let
  inherit (flake.inputs) jumphost-nix;
  homeMod = flake.inputs.self + /modules/home;
in
{
  imports = [
    "${jumphost-nix}/module.nix"
    "${homeMod}/agenix.nix"
    ./juspay-run.nix
    # "${homeMod}/claude-code/juspay.nix"  # Disabled: not using Claude Code at Juspay
  ];

  programs.jumphost = {
    enable = true;
    host = "nix-infra@idli-01.tail12b27.ts.net";

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

  # Keep the launchd/systemd ssh -D tunnel from going silent-dead.
  programs.ssh.settings.${config.programs.jumphost.host} = {
    ServerAliveInterval = 30;
    ServerAliveCountMax = 3;
    ExitOnForwardFailure = "yes";
  };

  home.shellAliases = {
    jcurl = "curl --socks5 localhost:1080";
  };
}
