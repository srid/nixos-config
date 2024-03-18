{ config, pkgs, lib, ... }:
{
  options = {
    my.helix = {
      markdown.enable = lib.mkEnableOption "Enable markdown support" // { default = true; };
    };
  };

  config.programs.helix = {
    enable = true;
    extraPackages = lib.optional config.my.helix.markdown.enable pkgs.marksman;
    settings = {
      theme = "snazzy";
      editor.true-color = true;
      keys = {
        insert.j.j = "normal_mode";
        # Shortcut to save file, in any mode.
        insert."C-s" = [ ":write" "normal_mode" ];
        normal."C-s" = ":write";
      };

      editor.lsp = {
        display-messages = true;
        display-inlay-hints = true;
        display-signature-help-docs = true;
      };
    };
  };
}
