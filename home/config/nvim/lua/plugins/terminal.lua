-- Terminal management via snacks.nvim (already loaded as claudecode.nvim dependency).
-- No `config` here — lazy.nvim merges opts from all specs and calls snacks.setup() once.
return {
  {
    "folke/snacks.nvim",
    opts = {
      notifier = { enabled = true },
      terminal = {
        -- NOTE: do not put `env` here — it becomes part of the terminal ID used
        -- by toggle(), and merging it inside M.open() causes an ID mismatch that
        -- makes toggle() assert "Terminal was not created".
        win = { position = "bottom", height = 0.35 },
      },
      lazygit = {
        win = {
          style  = "lazygit",
          border = "rounded",
          width  = 0.95,
          height = 0.90,
        },
        on_close = function()
          pcall(function() require('gitsigns').refresh() end)
        end,
      },
    },
    init = function()
      require("which-key").add({ { "<leader>t", group = "[t]erminal" } })

      -- Enter insert mode whenever focus lands on any terminal buffer.
      -- BufEnter is more reliable than WinEnter+defer: it fires exactly when
      -- the buffer becomes active, after snacks/nvim have finished setting up.
      vim.api.nvim_create_autocmd('BufEnter', {
        callback = function()
          if vim.bo.buftype == 'terminal' then
            vim.cmd('startinsert')
          end
        end,
      })
    end,
    keys = {
      {
        "<leader>tt",
        function()
          vim.cmd("tabe term://" .. vim.o.shell)
        end,
        desc = "[T]erminal tab",
      },
      {
        "<leader>tf",
        function()
          require("snacks").terminal.toggle(nil, { win = { position = "float", border = "rounded" } })
        end,
        desc = "[F]loat terminal",
      },
      {
        "<leader>tj",
        function()
          require("snacks").terminal.toggle(nil, { win = { position = "bottom" } })
        end,
        desc = "[J] lower (horizontal) terminal",
      },
      {
        "<leader>tl",
        function()
          require("snacks").terminal.toggle(nil, { win = { position = "right" } })
        end,
        desc = "[L] right (vertical) terminal",
      },
      {
        "<leader>tg",
        function() require("snacks").lazygit() end,
        desc = "Laz[y]git",
      },
    },
  },
}
