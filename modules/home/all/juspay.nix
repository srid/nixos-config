# For Juspay work
{ pkgs, config, ... }:
let
  vanjaram = "vanjaram.tail12b27.ts.net"; # Shared with my tailnet
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      # For git cloning via another jump host
      "ssh.bitbucket.juspay.net" = {
        user = "git";

        # This is the magic line that routes traffic 
        # through the other machine
        proxyJump = vanjaram;

        # Download this from 1Password
        identityFile = "~/.ssh/juspay.pub";
      };
      "${vanjaram}" = {
        forwardAgent = true;
      };
    };
  };

  programs.git = {
    # Bitbucket git access and policies
    includes = [{
      condition = "gitdir:~/juspay/**";
      contents = {
        user.email = "sridhar.ratnakumar@juspay.in";
      };
    }];
  };

  # SOCKS5 proxy via SSH tunnel to vanjaram
  launchd.agents.juspay-socks5-proxy = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.openssh}/bin/ssh"
        "-D" # Dynamic port forwarding (SOCKS proxy)
        "1080"
        "-N" # Don't execute remote command
        # "-q" # Quiet mode (suppress warnings)
        "-C" # Enable compression
        vanjaram
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/socks5-proxy.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/socks5-proxy.err";
    };
  };
}
