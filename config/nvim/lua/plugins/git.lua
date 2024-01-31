return {
  {
    "lewis6991/gitsigns.nvim",
    name = 'gitsigns',
    dependencies = {
      'sindrets/diffview.nvim'
    },
    config = function()
      require("diffview").setup({
        view = {
          merge_tool = {
            layout = "diff3_mixed"
          }
        }
      })
      local gs = require('gitsigns')
      require('which-key').register({ ["<leader>g"] = { name = "+[g]it" } })
      vim.keymap.set('n', '<leader>gp', gs.prev_hunk, { desc = "[P]revious Hunk" })
      vim.keymap.set('n', '<leader>gn', gs.next_hunk, { desc = "[N]ext Hunk" })
      vim.keymap.set('n', '<leader>gt', gs.toggle_current_line_blame, { desc = "[T]oggle current line blame" })
      vim.keymap.set('n', '<leader>gT', gs.toggle_deleted, { desc = "[T]oggle deleted" })
      vim.keymap.set('n', '<leader>gb', function() gs.blame_line { full = true } end, { desc = "[B]lame line" })
      vim.keymap.set('n', '<leader>gs', gs.stage_hunk, { desc = "[S]tage hunk" })
      vim.keymap.set('n', '<leader>gr', gs.reset_hunk, { desc = "[R]eset hunk" })
      vim.keymap.set('v', '<leader>gs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "[S]tage lines" })
      vim.keymap.set('v', '<leader>gr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "[R]eset lines" })
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
  {
    'pwntester/octo.nvim',
    config = function()
      require('octo').setup({
        pull_requests = {
          order_by = {                           -- criteria to sort the results of `Octo pr list`
            field = "UPDATED_AT",                -- either COMMENTS, CREATED_AT or UPDATED_AT (https://docs.github.com/en/graphql/reference/enums#issueorderfield)
            direction = "DESC"                   -- either DESC or ASC (https://docs.github.com/en/graphql/reference/enums#orderdirection)
          },
        }}
      )
      require('which-key').register({ ["<leader>go"] = { name = "+[O]cto" } })
      vim.keymap.set('n', '<leader>goa', "<cmd>Octo actions<cr>", { desc = "[A]ctions" })
      vim.keymap.set('n', '<leader>gor', "<cmd>Octo review start<cr>", { desc = "[R]eview Start" })
      vim.keymap.set('n', '<leader>gos', "<cmd>Octo review submit<cr>", { desc = "Review [S]ubmit" })
      vim.keymap.set('n', '<leader>goc', "<cmd>Octo comment add<cr>", { desc = "[C]omment add" })
    end,
  }
}
