{ lib, pkgs, ... }:
{
  home.packages = [ pkgs._1password-cli ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        # 1Password SSH agent
        IdentityAgent =
          if pkgs.stdenv.hostPlatform.isDarwin then
            # Path has a space; OpenSSH needs a backslash escape.
            "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock"
          else
            "~/.1password/agent.sock";
      };
    } // lib.genAttrs [ "pureintent" "sincereintent" ] (_: {
      ForwardAgent = true;
    });
  };
}
