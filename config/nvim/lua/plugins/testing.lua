return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      'olimorris/neotest-rspec',
    },
    config = function()
      require('neotest').setup({
        adapters = {
          require('neotest-rspec')({
            rspec_cmd = "bin/rspec"
          }),
        },
        quickfix = {
          enabled = false,
          open = false
        },
        discovery = {
          enabled = false
        }
      })
      require('which-key').register({ ["<leader>t"] = { name = "+ [t]est" } })
      vim.keymap.set('n', "<leader>tt", function() require("neotest").run.run() end, { desc = "[t] Nearest" })
      vim.keymap.set('n', "<leader>tl", function() require("neotest").run.run_last() end, { desc = "[L]ast" })
      vim.keymap.set('n', "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "[F]ile" })
      vim.keymap.set('n', "<leader>tS", function() require("neotest").run.stop() end, { desc = "[S]top" })
      vim.keymap.set('n', "<leader>ta", function() require("neotest").run.attach() end, { desc = "[A]ttach" })
      vim.keymap.set('n', "<leader>to", function() require("neotest").output.open({ enter = true }) end, { desc = "[O]utput" })
      vim.keymap.set('n', "<leader>tO", function() require("neotest").output_panel.toggle() end, { desc = "[O]utput Panel" })
      vim.keymap.set('n', "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "[S]ummary" })
      vim.keymap.set('n', "<leader>tp", function() require("neotest").jump.prev({ status = "failed" }) end, { desc = "[P]evious" })
      vim.keymap.set('n', "<leader>tn", function() require("neotest").jump.next({ status = "failed" }) end, { desc = "[N]ext" })
    end
  },
  {
    'andythigpen/nvim-coverage',
    config = function()
      require('coverage').setup()

      vim.keymap.set('n', "<leader>tc", function() require("coverage").load(true) end, { desc = "[C]overage" })
      vim.keymap.set('n', "<leader>th", function() require("coverage").hide() end, { desc = "Coverage [H]ide" })
    end
  }
}
