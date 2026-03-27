return {
  {
    "MagicDuck/grug-far.nvim",
    opts = {},
    keys = {
      { "<leader>s", function() require("grug-far").open() end,                                                              desc = "Find and Replace" },
      { "<leader>S", function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end,          desc = "Find and Replace (word)" },
      { "<leader>s", function() require("grug-far").with_visual_selection() end, mode = "v",                                 desc = "Find and Replace (selection)" },
    },
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
