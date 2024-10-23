{ flake, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];
  programs.nixvim = {
    enable = true;

    imports = [
      ./nvim-tree.nix
      ./lazygit.nix
    ];

    # Theme
    colorschemes.rose-pine.enable = true;
    # colorschemes.onedark.enable = true;

    # Settings
    opts = {
      expandtab = true;
      shiftwidth = 2;
      smartindent = true;
      tabstop = 2;
      number = true;
      clipboard = "unnamedplus";
    };

    # Keymaps
    globals = {
      mapleader = " ";
    };

    plugins = {
      # UI
      web-devicons.enable = true;
      lualine.enable = true;
      bufferline.enable = true;
      treesitter = {
        enable = true;
      };
      haskell-scope-highlighting.enable = true;
      which-key = {
        enable = true;
      };
      noice = {
        # WARNING: This is considered experimental feature, but provides nice UX
        enable = true;
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          #inc_rename = false;
          #lsp_doc_border = false;
        };
      };
      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = {
            options.desc = "file finder";
            action = "find_files";
          };
          "<leader>fr" = {
            options.desc = "recent files";
            action = "oldfiles";
          };
          "<leader>fg" = {
            options.desc = "find via grep";
            action = "live_grep";
          };
          "<leader>T" = {
            options.desc = "switch colorscheme";
            action = "colorscheme";
          };
        };
        extensions = {
          file-browser.enable = true;
          ui-select.enable = true;
          frecency.enable = true;
          fzf-native.enable = true;
        };
      };

      # LSP
      # https://github.com/nix-community/nixvim/blob/main/plugins/lsp/default.nix
      lsp = {
        enable = true;
        keymaps = {
          lspBuf = {
            "gd" = "definition";
            "gD" = "references";
            "gt" = "type_definition";
            "gi" = "implementation";
            "K" = "hover";
            "<leader>A" = "code_action";
          };
          diagnostic = {
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };
        };
        servers = {
          hls = {
            enable = true;
            installGhc = false;
          };
          marksman.enable = true;
          nil_ls.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
        };
      };
    };
  };
}
