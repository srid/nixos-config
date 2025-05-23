{ pkgs, flake, ... }:
let
  package =
    #if pkgs.stdenv.isDarwin then
    # Upstream has broken mac package
    # pkgs.gitAndTools.gitFull.override { svnSupport = false; }
    #else
    pkgs.gitAndTools.git;
in
{
  home.packages = with pkgs; [
    git-filter-repo
  ];

  programs.git = {
    inherit package;
    # difftastic.enable = true;
    enable = true;
    userName = flake.config.me.fullname;
    userEmail = flake.config.me.email;
    aliases = {
      co = "checkout";
      ci = "commit";
      cia = "commit --amend";
      s = "status";
      st = "status";
      b = "branch";
      # p = "pull --rebase";
      pu = "push";
    };
    iniContent = {
      # Branch with most recent change comes first
      branch.sort = "-committerdate";
      # Remember and auto-resolve merge conflicts
      # https://git-scm.com/book/en/v2/Git-Tools-Rerere
      rerere.enabled = true;
    };
    ignores = [ "*~" "*.swp" ];
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "master"; # Undo breakage due to https://srid.ca/luxury-belief
      core.editor = "nvim";
      #protocol.keybase.allow = "always";
      credential.helper = "store --file ~/.git-credentials";
      pull.rebase = "false";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      # This looks better with the kitty theme.
      gui.theme = {
        lightTheme = false;
        activeBorderColor = [ "white" "bold" ];
        inactiveBorderColor = [ "white" ];
        selectedLineBgColor = [ "reverse" "white" ];
      };
    };
  };
}
