{ flake, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    gh
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    _1password
  ];

  programs.zsh.envExtra = lib.mkIf pkgs.stdenv.isDarwin ''
    # For 1Password CLI. This requires `pkgs.gh` to be installed.
    # source $HOME/.config/op/plugins.sh
  '';

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*".extraOptions = {
        identityAgent =
          if pkgs.stdenv.isDarwin
          then ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
          else ''"~/.1password/agent.sock"'';
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
      user.signingKey = flake.config.me.sshKey;
      gpg.format = "ssh";
      gpg.ssh.program =
        if pkgs.stdenv.isDarwin
        then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else "/run/current-system/sw/bin/op-ssh-sign";
      commit.gpgsign = true;
    };
  }];
}
