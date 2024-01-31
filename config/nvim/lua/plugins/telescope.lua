return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-telescope/telescope-fzy-native.nvim",
  },
  opts = {
    pickers = {
      find_files = {
        find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden" }
      },
    }
  },
  init = function()
    require("telescope").load_extension "file_browser"
    require('telescope').load_extension('fzy_native')
    require("which-key").register({
      ["<leader>f"] = { name = "[Telescope] +[F]ind" },
      ["<leader>r"] = { name = "[Telescope] +[R]uby" }
    })
  end,
  keys = function()
    local ts_builtin = require("telescope.builtin")
    local telescope = require("telescope")

    vim.keymap.set('n', "<Leader>ff", ts_builtin.find_files, { desc = "[F]iles" })
    vim.keymap.set('n', "<Leader>fF", function() ts_builtin.find_files({ no_ignore = true }) end,
      { desc = "[F]iles with Ignored" })
    vim.keymap.set('n', "<Leader>f/", ts_builtin.current_buffer_fuzzy_find, { desc = "Buffer fuzzy find" })
    vim.keymap.set('n', "<Leader>fr", ts_builtin.oldfiles, { desc = "Recently opened files" })
    vim.keymap.set('n', "<Leader>fb", function() telescope.extensions.file_browser.file_browser() end,
      { desc = "Open [B]rowser" })
    vim.keymap.set('n', "<Leader>fB", function() telescope.extensions.file_browser.file_browser({path = '%:p:h', select_buffer =true}) end,
      { desc = "Open [B]rowser in current path" })
    vim.keymap.set('n', "<Leader>fc", ts_builtin.command_history, { desc = "[C]ommand Histroy" })
    vim.keymap.set('n', "<Leader>fe", ts_builtin.resume, { desc = "R[e]sume" })
    -- vim.keymap.set('n', "<Leader>fr", ts_builtin.registers)
    vim.keymap.set('n', "<Leader>fm", ts_builtin.keymaps, { desc = "Key[m]aps" })
    vim.keymap.set('n', "<Leader>fy", ts_builtin.filetypes, { desc = "Filet[y]pes" })
    vim.keymap.set('n', "<Leader>fg", ts_builtin.git_status, { desc = "[G]itStatus" })
    vim.keymap.set('n', "<Leader>fn", ts_builtin.reloader, { desc = "Reloader" })
    vim.keymap.set('n', "<Leader>ft", ts_builtin.treesitter, { desc = "[T]reesitter" })
    vim.keymap.set('n', "<Leader>fh", ts_builtin.help_tags, { desc = "[H]elp Tags" })
    -- vim.keymap.set('n', "<Leader>fd", ts_builtin.diagnostics, { desc = "[D]iagnostics"} )
    vim.keymap.set('n', "<Leader>fs", ts_builtin.lsp_document_symbols, { desc = "LSP [S]ymobls" })

    -- ruby
    vim.keymap.set('n', "<Leader>rm", function()
      local find_command = { 'rg', '--files', '--hidden', '--follow', '--sortr=path', 'db/migrate' }
      ts_builtin.find_files({
        find_command = find_command
      })
    end, { desc = "Migrations" })
  end
}
