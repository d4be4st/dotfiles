return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = { hidden = true },
        },
      },
    },
    init = function()
      require("which-key").add({
        { "<leader>f", group = "[F]ind" },
        { "<leader>r", group = "[R]uby" },
      })
    end,
    keys = {
      { "<leader>ff", function() Snacks.picker.files() end,                                                  desc = "[F]iles" },
      { "<leader>fF", function() Snacks.picker.files({ ignored = true }) end,                                desc = "[F]iles with ignored" },
      { "<leader>f/", function() Snacks.picker.lines() end,                                                  desc = "Buffer fuzzy find" },
      { "<leader>fr", function() Snacks.picker.recent() end,                                                 desc = "[R]ecent files" },
      { "<leader>fb", function() Snacks.picker.files({ cwd = vim.fn.expand("%:p:h") }) end,                  desc = "File [B]rowser (current dir)" },
      { "<leader>fc", function() Snacks.picker.command_history() end,                                        desc = "[C]ommand history" },
      { "<leader>fe", function() Snacks.picker.resume() end,                                                 desc = "R[e]sume" },
      { "<leader>fm", function() Snacks.picker.keymaps() end,                                                desc = "Key[m]aps" },
      { "<leader>fg", function() Snacks.picker.git_status() end,                                             desc = "[G]it status" },
      { "<leader>fh", function() Snacks.picker.help() end,                                                   desc = "[H]elp tags" },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end,                                            desc = "LSP [S]ymbols" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end,                                            desc = "[D]iagnostics" },
      { "<leader>ft", function() Snacks.picker.treesitter() end,                                             desc = "[T]reesitter symbols" },
      -- ruby
      { "<leader>rm", function() Snacks.picker.files({ cwd = "db/migrate" }) end,                            desc = "[M]igrations" },
    },
  },
}
