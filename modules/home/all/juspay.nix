# For Juspay work
{
  programs.ssh = {
    matchBlocks = {
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
