return {
  {
    "lewis6991/gitsigns.nvim",
    name = 'gitsigns',
    config = function()
      local gs = require('gitsigns')
      require('which-key').add({ { "<leader>g", group = "[g]it" }, })

      -- Hunk navigation
      vim.keymap.set('n', '<leader>gp', gs.prev_hunk,                                            { desc = "[P]revious Hunk" })
      vim.keymap.set('n', '<leader>gn', gs.next_hunk,                                            { desc = "[N]ext Hunk" })
      vim.keymap.set('n', '<leader>gP', gs.preview_hunk,                                         { desc = "[P]review hunk" })

      -- Blame / diff
      vim.keymap.set('n', '<leader>gt', gs.toggle_current_line_blame,                            { desc = "[T]oggle current line blame" })
      vim.keymap.set('n', '<leader>gT', gs.toggle_deleted,                                       { desc = "[T]oggle deleted" })
      vim.keymap.set('n', '<leader>gb', function() gs.blame_line { full = true } end,            { desc = "[B]lame line" })
      vim.keymap.set('n', '<leader>gd', gs.diffthis,                                             { desc = "[d]iff" })
      vim.keymap.set('n', '<leader>gD', function() gs.diffthis('~') end,                         { desc = "[D]iff ~" })

      vim.keymap.set('n', '<leader>fg', function() Snacks.picker.git_branches() end, { desc = "[G]it checkout branch" })

      gs.setup()
    end,
  },
}
