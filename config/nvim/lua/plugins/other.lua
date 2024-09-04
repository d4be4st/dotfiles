return {
  -- coding
  { 'echasnovski/mini.comment',     config = function() require('mini.comment').setup({}) end },
  { 'echasnovski/mini.surround',    config = function() require('mini.surround').setup({}) end },
  { 'echasnovski/mini.indentscope', config = function() require('mini.indentscope').setup({}) end },
  { 'wakatime/vim-wakatime' },

  -- pane manipulations
  { "anuvyklack/windows.nvim",
    dependencies = "anuvyklack/middleclass",
    config = function()
      require('windows').setup(
        {
          autowidth = {
            enable = false
          }
        }
      )
      require('which-key').register({ ["<leader>w"] = { name = "+[w]indow" } })
      vim.keymap.set('n', "<leader>wm", require('windows.commands').maximize, { desc = "[M]aximize" })
      vim.keymap.set('n', "<leader>we", require('windows.commands').equalize, { desc = "[E]qualize" })
      vim.keymap.set('n', "<leader>wt", require('windows.autowidth').toggle, { desc = "[E]qualize" })
    end
  },
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({})
    end,
  },

  {
    'Wansmer/treesj',
    opts = {
      use_default_keymaps = false
    },
    keys = {
      { 'gS', function() require('treesj').split() end, desc = "Split code block" },
      { 'gJ', function() require('treesj').join() end,  desc = "Join code block" },
    }
  },
  {
    'stevearc/oil.nvim',
    config = function()
      require('oil').setup({
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        keymaps = {
          ["<C-v>"] = { "actions.select", opts = { vertical = true } },
          ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
        }
      })
      vim.keymap.set('n', '<leader>oe', "<CMD>Oil<CR>", { desc = "[E]xplore" })
    end
  },
  {
    "oysandvik94/curl.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("curl").setup({})
    end
  },
  {
    "johmsalas/text-case.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("textcase").setup({})
      require("telescope").load_extension("textcase")
    end,
    keys = {
      "<leader>a", -- Default invocation prefix
      { "<leader>af", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Telescope" },
    },
    cmd = {
      -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
      "Subs",
      "TextCaseOpenTelescope",
      "TextCaseOpenTelescopeQuickChange",
      "TextCaseOpenTelescopeLSPChange",
      "TextCaseStartReplacingCommand",
    },
    -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
    -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
    -- available after the first executing of it or after a keymap of text-case.nvim has been used.
    lazy = false,
  }
}
