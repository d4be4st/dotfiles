return {
  -- coding
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>fT", function() Snacks.picker.todo_comments() end,        desc = "[T]odo comments" },
    },
  },
  { 'echasnovski/mini.surround',    config = function() require('mini.surround').setup({}) end },
  { 'echasnovski/mini.indentscope', config = function() require('mini.indentscope').setup({}) end },
  -- { 'wakatime/vim-wakatime' },

  -- pane manipulations
  {
    "anuvyklack/windows.nvim",
    dependencies = "anuvyklack/middleclass",
    config = function()
      require('windows').setup(
        {
          autowidth = {
            enable = false
          }
        }
      )
      require('which-key').add({ { "<leader>w", group = "[w]indow" }, })
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
      { 'gJ', function() require('treesj').join() end,  desc = "Join code block" },
    }
  },
  {
    'stevearc/oil.nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
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
    "johmsalas/text-case.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("textcase").setup({})
    end,
    keys = {
      -- "<leader>a", -- Default invocation prefix
      -- { "<leader>af", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Telescope" },
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
  },
  {
    'stevearc/overseer.nvim',
    config = function()
      local overseer = require('overseer')
      overseer.setup({})
      overseer.register_template({
        name = "gleam",
        builder = function()
          local file = vim.fn.expand("%:t:r")
          return {
            cmd = { "gleam" },
            args = { "run", "-m", file },
          }
        end,
        condition = {
          filetype = { "gleam" },
        },
      })
      overseer.register_template({
        name = "erblint",
        builder = function()
          local file = vim.fn.expand("%:p")
          return {
            cmd = { "erblint" },
            args = { "-a", file },
          }
        end,
        condition = {
          filetype = { "eruby" },
        },
      })
      local restart = function()
        local tasks = overseer.list_tasks({ recent_first = true })
        if vim.tbl_isempty(tasks) then
          vim.notify("No tasks found", vim.log.levels.WARN)
        else
          overseer.run_action(tasks[1], "restart")
        end
      end
      vim.keymap.set('n', "<leader>rl", restart, { desc = "Run [l]atest" })
      vim.keymap.set('n', "<leader>rr", "<CMD>OverseerRun<CR>", { desc = "Run Ove[r]seer", silent = true })
      vim.keymap.set('n', "<leader>rg", "<CMD>OverseerRun gleam<CR>", { desc = "Run [G]leam", silent = true })
      vim.keymap.set('n', "<leader>ro", "<CMD>OverseerOpen!<CR>", { desc = "Open [O]utput", silent = true })
    end
  },
  {
    "nosduco/remote-sshfs.nvim",
    opts = {
    },
  }
}
