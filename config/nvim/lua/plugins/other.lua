return {
  -- coding
  { 'echasnovski/mini.comment', config = function() require('mini.comment').setup({}) end },
  { 'echasnovski/mini.surround', config = function() require('mini.surround').setup({}) end },
  { 'echasnovski/mini.indentscope', config = function() require('mini.indentscope').setup({}) end },
  { 'echasnovski/mini.pairs', config = function() require("mini.pairs").setup({}) end },

  -- smooth scrolling
  {
    'declancm/cinnamon.nvim',
    opts = {
      extra_keymaps = true,
      extended_keymaps = true
    },
  },

  -- file manipulation
  {
    "chrisgrieser/nvim-genghis",
    dependencies = "stevearc/dressing.nvim",
    keys = function()
      local genghis = require('genghis')
      require('which-key').register({ ["<leader>o"] = { name = "[o] +file" } })
      vim.keymap.set('n', "<leader>os", genghis.duplicateFile, { desc = "[S]ave as new file" })
      vim.keymap.set('n', "<leader>ox", genghis.chmodx, { desc = "Make current file e[x]ecutable" })
      vim.keymap.set('n', "<leader>or", genghis.renameFile, { desc = "[R]ename file" })
      vim.keymap.set('n', "<leader>om", genghis.moveAndRenameFile, { desc = "[M]ove file" })
      vim.keymap.set('n', "<leader>od", genghis.trashFile, { desc = "[D]elete file" })
      vim.keymap.set('n', "<leader>oc", genghis.createNewFile, { desc = "[C]reate file" })
      vim.keymap.set("x", "<leader>on", genghis.moveSelectionToNewFile, { desc = "Move selection to [N]ew File" })
    end
  },

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
    'Wansmer/treesj',
    opts = {
      use_default_keymaps = false
    },
    keys = {
      { 'gS', function() require('treesj').split() end, desc = "Split code block" },
      { 'gJ', function() require('treesj').join() end, desc = "Join code block" },
    }
  },

  -- obisidan
  {
    'epwalsh/obsidian.nvim',
    opts = {
      dir = "~/dev/obsidian",
      completion = {
        nvim_cmp = true, -- if using nvim-cmp, otherwise set to false
      }
    }
  }
}
