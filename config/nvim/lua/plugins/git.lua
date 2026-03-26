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
      require('which-key').add({ { "<leader>g", group = "[g]it" }, })

      -- Hunk navigation
      vim.keymap.set('n', '<leader>gp', gs.prev_hunk,                                            { desc = "[P]revious Hunk" })
      vim.keymap.set('n', '<leader>gn', gs.next_hunk,                                            { desc = "[N]ext Hunk" })
      vim.keymap.set('n', '<leader>gP', gs.preview_hunk,                                         { desc = "[P]review hunk" })

      -- Staging / resetting
      vim.keymap.set('n', '<leader>gs', gs.stage_hunk,                                           { desc = "[S]tage hunk" })
      vim.keymap.set('v', '<leader>gs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "[S]tage lines" })
      vim.keymap.set('n', '<leader>gS', gs.stage_buffer,                                         { desc = "[S]tage buffer" })
      vim.keymap.set('n', '<leader>gu', gs.undo_stage_hunk,                                      { desc = "[U]ndo stage hunk" })
      vim.keymap.set('n', '<leader>gr', gs.reset_hunk,                                           { desc = "[R]eset hunk" })
      vim.keymap.set('v', '<leader>gr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = "[R]eset lines" })
      vim.keymap.set('n', '<leader>gR', gs.reset_buffer,                                         { desc = "[R]eset buffer" })

      -- Blame / diff
      vim.keymap.set('n', '<leader>gt', gs.toggle_current_line_blame,                            { desc = "[T]oggle current line blame" })
      vim.keymap.set('n', '<leader>gT', gs.toggle_deleted,                                       { desc = "[T]oggle deleted" })
      vim.keymap.set('n', '<leader>gb', function() gs.blame_line { full = true } end,            { desc = "[B]lame line" })
      vim.keymap.set('n', '<leader>gd', gs.diffthis,                                             { desc = "[d]iff" })
      vim.keymap.set('n', '<leader>gD', function() gs.diffthis('~') end,                         { desc = "[D]iff ~" })
      vim.keymap.set('n', '<leader>gg', function() require("diffview").open() end,               { desc = "Diff[v]iew" })

      -- Status float
      vim.keymap.set('n', '<leader>gi', function()
        local lines = vim.fn.systemlist('git status --short')
        if vim.v.shell_error ~= 0 or #lines == 0 then
          lines = { '(nothing to show)' }
        end
        local width = 60
        for _, l in ipairs(lines) do
          if #l + 2 > width then width = #l + 2 end
        end
        local height = math.min(#lines, 20)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        local win = vim.api.nvim_open_win(buf, true, {
          relative = 'editor',
          width = width,
          height = height,
          row = math.floor((vim.o.lines - height) / 2),
          col = math.floor((vim.o.columns - width) / 2),
          style = 'minimal',
          border = 'rounded',
          title = ' git status ',
          title_pos = 'center',
        })
        vim.keymap.set('n', 'q',     function() vim.api.nvim_win_close(win, true) end, { buffer = buf, nowait = true })
        vim.keymap.set('n', '<ESC>', function() vim.api.nvim_win_close(win, true) end, { buffer = buf, nowait = true })
      end, { desc = "[i]nspect status" })

      -- Commit (input prompt)
      vim.keymap.set('n', '<leader>gc', function()
        vim.ui.input({ prompt = 'Commit message: ' }, function(msg)
          if not msg or msg == '' then return end
          local result = vim.fn.system('git commit -m ' .. vim.fn.shellescape(msg))
          vim.notify(result, vim.log.levels.INFO)
        end)
      end, { desc = "[C]ommit" })

      vim.keymap.set('n', '<leader>gC', function()
        vim.ui.input({ prompt = 'Commit message (add all): ' }, function(msg)
          if not msg or msg == '' then return end
          local result = vim.fn.system('git commit -a -m ' .. vim.fn.shellescape(msg))
          vim.notify(result, vim.log.levels.INFO)
        end)
      end, { desc = "[C]ommit -a (stage all)" })

      -- Add all + push (terminal)
      local term_win = { position = "bottom" }
      local function git_term(cmd)
        require('snacks').terminal.toggle(cmd, { interactive = false, win = term_win })
      end
      vim.keymap.set('n', '<leader>ga', function() git_term('git add . && git status') end, { desc = "[A]dd all" })
      vim.keymap.set('n', '<leader>gX', function() git_term('git push') end,                { desc = "Push [X]" })

      gs.setup()
    end,
  },
  {
    "almo7aya/openingh.nvim",
    config = function()
      require("openingh").setup({})
      vim.keymap.set('n', '<leader>gl', ":OpenInGHFileLines <CR>", { desc = "Open in GitHub [L]ines" })
      vim.keymap.set('v', '<leader>gl', ":OpenInGHFileLines <CR>", { desc = "Open in GitHub [L]ines" })
      vim.keymap.set('n', '<leader>gf', ":OpenInGHFile <CR>",      { desc = "Open in GitHub [F]ile" })
    end
  }
}
