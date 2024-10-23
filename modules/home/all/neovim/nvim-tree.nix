{
  plugins.nvim-tree.enable = true;
  keymaps = [
    {
      action = "<cmd>NvimTreeFindFileToggle<CR>";
      key = "<leader>tt";
    }
    {
      action = "<cmd>NvimTreeFindFile<CR>";
      key = "<leader>tf";
    }
  ];
}
