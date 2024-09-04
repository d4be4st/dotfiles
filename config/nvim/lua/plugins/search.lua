return {
  {
    'windwp/nvim-spectre',
    keys = {
      {'<leader>s', function() require('spectre').open() end, 'n', desc = "Open [S]pectre"},
      {'<leader>S', function() require('spectre').open_visual({select_word=true}) end, desc = "Open [S]pectre with word"},
      {'<leader>s', function() require('spectre').open_visual() end, 'v', desc = "Open [S]pectre with selection"},
    },
    config = function ()
      require('spectre').setup()
    end
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = true
        }
      }
    },
    -- stylua: ignore
    keys = {
      { "<leader>/", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  }
}
