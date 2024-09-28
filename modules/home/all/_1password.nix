{ flake, config, pkgs, lib, ... }:
let
  userConfig = flake.config.people.users.${config.home.username};
in
{
  home.packages = with pkgs; [
    _1password
    gh
  ];

  programs.zsh.envExtra = ''
    # For 1Password CLI. This requires `pkgs.gh` to be installed.
    # source $HOME/.config/op/plugins.sh
  '';

  programs.ssh = {
    enable = true;
    matchBlocks = {
      # Configure 1Password agent only on macOS; whilst using agent forwarding
      # to make it available to Linux machines.
      "*".extraOptions = lib.mkIf pkgs.stdenv.isDarwin {
        identityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
      };
    };
  };

  # https://developer.1password.com/docs/ssh/git-commit-signing/
  # 
  # For this to work on GitHub, you must have added the SSH pub key as a signing key, see
  # https://1password.community/discussion/comment/667515/#Comment_667515
  programs.git.includes = [{
    condition = "gitdir:~/code/**"; # Personal repos only
    contents = {
      user.signingKey = userConfig.sshKey;
      gpg.format = "ssh";
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      commit.gpgsign = true;
    };
  }];
}
