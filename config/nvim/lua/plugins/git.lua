return {
  {
    "lewis6991/gitsigns.nvim",
    name = 'gitsigns',
    dependencies = {
      'sindrets/diffview.nvim'
    },
    config = function()
      local gs = require('gitsigns')
      require('which-key').register({ ["<leader>g"] = { name = "+[g]it" } })
      vim.keymap.set('n', '<leader>gp', gs.prev_hunk, { desc = "[P]revious Hunk" })
      vim.keymap.set('n', '<leader>gn', gs.next_hunk, { desc = "[N]ext Hunk" })
      vim.keymap.set('n', '<leader>gt', gs.toggle_current_line_blame, { desc = "[T]oggle current line blame" })
      vim.keymap.set('n', '<leader>gT', gs.toggle_deleted, { desc = "[T]oggle deleted" })
      vim.keymap.set('n', '<leader>gb', function() gs.blame_line { full = true } end, { desc = "[B]lame line" })
      vim.keymap.set({ 'n', 'v' }, '<leader>gs', gs.stage_hunk, { desc = "[S]tage hunk" })
      vim.keymap.set({ 'n', 'v' }, '<leader>gr', gs.reset_hunk, { desc = "[R]eset hunk" })
      vim.keymap.set('n', '<leader>gS', gs.stage_buffer, { desc = "[S]tage buffer" })
      vim.keymap.set('n', '<leader>gu', gs.undo_stage_hunk, { desc = "[U]ndo stage hunk" })
      vim.keymap.set('n', '<leader>gR', gs.reset_buffer, { desc = "[R]eset buffer" })
      vim.keymap.set('n', '<leader>gP', gs.preview_hunk, { desc = "[P]review hunk" })
      vim.keymap.set('n', '<leader>gd', gs.diffthis, { desc = "[d]iff" })
      vim.keymap.set('n', '<leader>gD', function() gs.diffthis('~') end, { desc = "[D]iff" })
      vim.keymap.set('n', '<leader>gg', function() require("diffview").open() end, { desc = "[D]iff" })

      gs.setup()
    end,
  },
}
