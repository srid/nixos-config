# For Juspay work
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
}
