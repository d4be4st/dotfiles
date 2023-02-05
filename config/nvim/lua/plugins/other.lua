return {
  { 'echasnovski/mini.comment', config = function() require('mini.comment').setup({}) end },
  { 'echasnovski/mini.surround', config = function() require('mini.surround').setup({}) end },
  { 'echasnovski/mini.indentscope', config = function() require('mini.indentscope').setup({}) end },
  { 'echasnovski/mini.pairs', config = function() require("mini.pairs").setup({}) end },
  { "lewis6991/gitsigns.nvim", config = true },
  { 'declancm/cinnamon.nvim', opts = {
    extra_keymaps = true,
    extended_keymaps = true
  },
  },
  { "chrisgrieser/nvim-genghis", dependencies = "stevearc/dressing.nvim" },
  'windwp/nvim-spectre',
  { 'sindrets/diffview.nvim' },
  { "cshuaimin/ssr.nvim", name = "ssr" },
  "ggandor/leap.nvim",
  { "anuvyklack/windows.nvim",
    dependencies = "anuvyklack/middleclass",
    opts = {
      autowidth = {
        enable = false
      }
    }
  },
}
