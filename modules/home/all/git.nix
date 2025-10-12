{ pkgs, flake, ... }:
{
  home.packages = with pkgs; [
    git-filter-repo
  ];

  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
        pager = "${pkgs.less}/bin/less --mouse --wheel-lines=3";
      };
    };
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
    ignores = [ "*~" "*.swp" ];
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "master"; # Undo breakage due to https://srid.ca/luxury-belief
      #protocol.keybase.allow = "always";
      credential.helper = "store --file ~/.git-credentials";
      pull.rebase = "false";

      # Branch with most recent change comes first
      branch.sort = "-committerdate";
      # Remember and auto-resolve merge conflicts
      # https://git-scm.com/book/en/v2/Git-Tools-Rerere
      rerere.enabled = true;
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
