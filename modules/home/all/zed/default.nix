# https://github.com/nix-community/home-manager/blob/master/modules/programs/zed-editor.nix
{
  home.file.".config/zed/themes".source = ./themes;

  programs.zed-editor = {
    enable = true;

    # https://github.com/zed-industries/extensions/tree/main/extensions
    extensions = [
      "just"
      "toml"
      "nix"
    ];

    userSettings = {
      imports = [ ./remote-projects.nix ];

      vim_mode = true;
      base_keymap = "VSCode";
      soft_wrap = "editor_width";
      tab_size = 2;

      # direnv
      load_direnv = "shell_hook";
      languages.Nix.language_servers = [ "nixd" "!nil" ]; # Force use of nixd over nil
      lsp =
        let
          useDirenv = { binary.path_lookup = true; };
        in
        {
          haskell = useDirenv;
          rust_analyzer = useDirenv;
          # FIXME: This won't work unless Zed is started inside of direnv shell.
          nixd = useDirenv;
        };

      # Look & feel
      ui_font_size = 16;
      ui_font_family = "Cascadia Code";
      buffer_font_size = 14;
      theme = {
        mode = "system";
        light = "Catppuccin Mocha";
        dark = "One Dark";
      };

      # Layout
      outline_panel = {
        dock = "right";
      };
      project_panel = {
        dock = "right";
      };
    };
  };
}
