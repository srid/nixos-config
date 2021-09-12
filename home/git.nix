{
  # package = pkgs.gitAndTools.gitFull;
  enable = true;
  userName = "Sridhar Ratnakumar";
  userEmail = "srid@srid.ca";
  aliases = {
    co = "checkout";
    ci = "commit";
    cia = "commit --amend";
    s = "status";
    st = "status";
    b = "branch";
    p = "pull --rebase";
    pu = "push";
  };
  ignores = [ "*~" "*.swp" ];
  extraConfig = {
    init.defaultBranch = "master";
    #core.editor = "nvim";
    #protocol.keybase.allow = "always";
    credential.helper = "store --file ~/.git-credentials";
    pull.rebase = "false";
  };
}
