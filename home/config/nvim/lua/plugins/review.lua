return {
  -- review.nvim's `c` (list comments) renders through vim.ui.select. Without a
  -- backend that is Neovim's built-in numbered cmdline prompt — a wall of text you
  -- cannot navigate. snacks is already installed; this points ui.select at its
  -- picker so `c` becomes a fuzzy-filterable, jumpable list.
  -- NOTE: global — every vim.ui.select in nvim (LSP code actions, etc.) uses it too.
  -- lazy merges opts from all specs, so this composes with the snacks spec in telescope.lua.
  { "folke/snacks.nvim", opts = { picker = { ui_select = true } } },
  {
    -- fork: upstream is frozen at v1.9.1 (2026-03-16). local-patches carries two fixes
    -- on top — a keymap guard so review's single-key maps stay off the comment popup,
    -- and Path-object normalization so it works with current codediff.
    -- Upstream: github.com/georgeguimaraes/review.nvim
    "d4be4st/review.nvim",
    branch = "local-patches",
    dependencies = {
      -- Unpinned: the fork's path_str()/session_paths() normalization handles both the
      -- old string return and the typed Path tables codediff returns since fe7ab20.
      "esmuellert/codediff.nvim",
      "MunifTanjim/nui.nvim",
    },
    cmd = { "Review" },
    -- init runs at startup even though the plugin is lazy-loaded, so `nvim -c ReviewOnly`
    -- resolves. :Review opens codediff in a NEW tab, leaving nvim's startup [No Name]
    -- tab behind; this drops it once codediff's tab exists. Hooks codediff's own
    -- CodeDiffOpen event rather than a delay — the tab is created asynchronously, so a
    -- plain `-c tabonly` runs too early and does nothing.
    init = function()
      vim.api.nvim_create_user_command("ReviewOnly", function()
        vim.api.nvim_create_autocmd("User", {
          pattern = "CodeDiffOpen",
          once = true,
          callback = function()
            vim.schedule(function()
              pcall(vim.cmd, "tabonly")
            end)
          end,
        })
        vim.cmd("Review")
      end, { desc = "Review, dropping the empty startup tab" })
    end,
    keys = {
      { "<leader>gv", "<cmd>Review<cr>",         desc = "Re[v]iew diff" },
      { "<leader>gV", "<cmd>Review commits<cr>", desc = "Re[V]iew commits" },
      { "<leader>gA", "<cmd>ReviewReload<cr>",   desc = "Reload review [A]nnotations" },
    },
    opts = {
      keymaps = {
        -- default is <localleader>cc, which shadows <leader>cc (toggle Claude tab)
        add_comment = "<localleader>ca",
      },
    },
    config = function(_, opts)
      -- unified diff: laptop screens don't have room for side-by-side. `t` toggles.
      require("codediff").setup({
        -- catppuccin's DiffAdd (#364143) and DiffDelete (#443244) are near-identical in
        -- lightness and barely saturated — fine for whole-file vimdiff, unreadable for
        -- an inline review. Explicit hex instead; char_brightness lifts the intra-line
        -- word-level highlight above the line background.
        highlights = {
          line_insert = "#16301f",
          line_delete = "#3d1c24",
          char_brightness = 1.6,
        },
        diff = { layout = "inline", compact = true, compact_context_lines = 5 },
        -- j/k in the explorer loads the file under the cursor into the diff pane
        -- without moving focus out of the explorer. Hooks j/k rather than CursorMoved,
        -- so scrolling and mouse clicks don't trigger a load.
        explorer = { auto_open_on_cursor = true },
        keymaps = {
          view = {
            next_hunk = "<C-n>",
            prev_hunk = "<C-p>",
          },
          -- default is S, which review.nvim's BufEnter stamp overwrites with
          -- send_sidekick, leaving stage-all unreachable. A pairs with U (unstage all).
          explorer = {
            stage_all = "A",
          },
        },
      })

      -- diff.compact is a one-shot default: codediff burns the latch on the first
      -- diff, then compact.refresh() turns compact OFF for any file with no hunks
      -- (added/untracked/deleted whole-file views) and it never returns. Re-arm the
      -- latch in exactly that case, so a hunkless file doesn't end compact for the tab.
      local compact = require("codediff.ui.view.compact")
      local cd_lifecycle = require("codediff.ui.lifecycle")
      local compact_refresh = compact.refresh
      compact.refresh = function(tabpage)
        compact_refresh(tabpage)
        local s = cd_lifecycle.get_session(tabpage)
        if s and not s.compact_mode then
          local changes = s.stored_diff_result and s.stored_diff_result.changes
          if not changes or #changes == 0 then
            s.compact_default_applied = false
          end
        end
      end

      -- j/k in the explorer jumps out of the sidebar the first time it lands on an
      -- UNSTAGED new file. codediff routes untracked (??) entries to
      -- inline_view.show_single_file with no revision, which loads the file through
      -- helpers.open_real_file -> nvim_set_current_win(mod_win) + :edit, and never gives
      -- focus back. Staged adds pass revision=":0" and take the virtual-buffer path,
      -- which never touches the current window -- hence "only when not staged". The
      -- steal also only happens on the first visit, since open_real_file skips :edit once
      -- the buffer is loaded. view.update already saves and restores the window; these
      -- two entry points forgot to.
      local function keep_current_win(module, fname)
        local original = module[fname]
        module[fname] = function(...)
          local win = vim.api.nvim_get_current_win()
          local ok, err = pcall(original, ...)
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
          end
          if not ok then
            error(err)
          end
        end
      end
      keep_current_win(require("codediff.ui.view.inline_view"), "show_single_file")
      keep_current_win(require("codediff.ui.view.side_by_side"), "show_untracked_file")

      require("review").setup(opts)

      -- Keep review notes inside the repo so they're deleted with the worktree.
      -- data_dir in review/storage.lua is a hardcoded local, but save/load/clear
      -- all route through this one exported function.
      -- Render comment boxes ABOVE the line instead of below. review.nvim hardcodes
      -- virt_lines_above = false (marks.lua), so wrap the render and flip it while it runs.
      -- Only single-line comments qualify: those set sign_text + virt_lines on the same
      -- extmark. Range comments anchor their box to the range's LAST line, so flipping
      -- those would draw the box inside the range instead of after it — left alone.
      local marks = require("review.marks")
      local render = marks.render_for_buffer
      marks.render_for_buffer = function(...)
        local set_extmark = vim.api.nvim_buf_set_extmark
        vim.api.nvim_buf_set_extmark = function(buf, ns, row, col, o)
          if o and o.virt_lines and o.sign_text then
            o.virt_lines_above = true
          end
          return set_extmark(buf, ns, row, col, o)
        end
        local ok, err = pcall(render, ...)
        vim.api.nvim_buf_set_extmark = set_extmark
        if not ok then
          error(err)
        end
      end

      -- review.nvim's setup_keymaps installs a BufEnter autocmd that stamps its
      -- single-key readonly maps onto EVERY buffer entered in the review tab — the
      -- comment popup included. That shadows i/d/c/e in a buffer whose whole job is
      -- editing text, so `i` reports "can't add comment" instead of entering insert.
      -- Strip them from the popup buffer once it's focused. All of the popup's own
      -- maps (<C-s>, <CR>, <Esc>, q, <Tab>) live on the same buffer and are untouched.
      -- review.nvim paints a full-line background on every annotated line
      -- (ReviewNoteLine = #0d1f28 etc). That sits on top of the diff background, so a
      -- commented line no longer reads as added or removed — and on a range comment it
      -- flattens ten lines at once. The gutter sign and the comment box already mark the
      -- annotation, so drop the tint. Its groups are default=true, so a plain set wins.
      local function clear_review_line_hl()
        for _, group in ipairs({
          "ReviewNoteLine",
          "ReviewSuggestionLine",
          "ReviewIssueLine",
          "ReviewPraiseLine",
        }) do
          vim.api.nvim_set_hl(0, group, {})
        end
      end
      clear_review_line_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("review_line_hl", { clear = true }),
        callback = clear_review_line_hl,
      })

      -- Claude rewrites .review.json while the tab is open, but store.load() guards on a
      -- `loaded` flag set at open time and marks.refresh() only re-renders the in-memory
      -- table — so new annotations never appear. reset() clears that flag. Reload before
      -- commenting: adding a comment persists the stale in-memory set over the whole file.
      vim.api.nvim_create_user_command("ReviewReload", function()
        local store = require("review.store")
        store.reset()
        store.load()
        require("review.marks").refresh()
        vim.notify(("%d annotations"):format(store.count()), vim.log.levels.INFO, { title = "review.nvim" })
      end, { desc = "Reload annotations from .review.json" })

      -- `r` inside the review tab, on top of <leader>gA. Free in both plugins: review.nvim
      -- binds i/d/e/c/C/S/F/R/q/f/?, codediff's panels use R/i/K/S/U/X. Readonly mode is the
      -- default and makes the diff buffers nomodifiable, so vim's replace-char is already dead
      -- there; the cost is losing it after `R` flips to edit mode. set_tab_keymap covers both
      -- diff panes and the explorer, and the session registry drops the map with the tab.
      -- Re-run on FileSelect too: a layout toggle recreates the buffers.
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("review_reload_key", { clear = true }),
        pattern = { "CodeDiffOpen", "CodeDiffFileSelect" },
        callback = function()
          vim.defer_fn(function()
            local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
            if ok then
              lifecycle.set_tab_keymap(vim.api.nvim_get_current_tabpage(), "n", "r", function()
                vim.cmd("ReviewReload")
              end, { desc = "Reload review annotations" })
            end
          end, 150)
        end,
      })

      local storage = require("review.storage")
      storage.get_storage_path = function()
        local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        if not root or root == "" then
          return nil
        end
        return root .. "/.review.json"
      end
    end,
  },
}
