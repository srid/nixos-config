# For Juspay work
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      # To clone Juspay repos.
      # https://developer.1password.com/docs/ssh/agent/advanced/#match-key-with-host
      #
      # Download these from 1Password
      "bitbucket.org" = {
        identitiesOnly = true;
        identityFile = "~/.ssh/juspay.pub";
      };
      "ssh.bitbucket.juspay.net" = {
        identityFile = "~/.ssh/juspay.pub";
      };

      # For git cloning via another jump host
      "ssh.bitbucket.juspay.net" = {
        user = "git";

        # This is the magic line that routes traffic 
        # through the other machine
        proxyJump = "vanjaram";
      };
      "vanjaram" = {
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
}
