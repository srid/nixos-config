# For Juspay work
let
  # I don't care to connect to VPN on my macbook
  # So, I'll clone through an office machine
  gitCloneThrough = { host, user }:
    let
      port = 5445;
      gitSshRemote = "ssh.bitbucket.juspay.net";
    in
    {
      programs.ssh.matchBlocks = {
        ${host} = {
          inherit user;
          dynamicForwards = [{ inherit port; }];
        };
        ${gitSshRemote} = {
          user = "git";
          proxyCommand = "nc -x localhost:${builtins.toString port} %h %p";
        };
      };
    };
in
{
  imports = [
    (gitCloneThrough { host = "vanjaram"; user = "srid"; })
  ];
  programs.ssh = {
    matchBlocks = {
      # Juspay machines (through Tailscale)
      vanjaram = {
        hostname = "100.83.79.127";
        user = "srid";
        forwardAgent = true;
      };
      biryani = {
        hostname = "100.97.32.60";
        user = "admin";
        forwardAgent = true;
      };

      # To clone Juspay repos.
      # https://developer.1password.com/docs/ssh/agent/advanced/#match-key-with-host
      "bitbucket.org" = {
        identitiesOnly = true;
        identityFile = "~/.ssh/juspay.pub";
      };
      "ssh.bitbucket.juspay.net" = {
        identityFile = "~/.ssh/juspay.pub";
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
}

