return {
  -- coding
  { 'echasnovski/mini.comment',     config = function() require('mini.comment').setup({}) end },
  { 'echasnovski/mini.surround',    config = function() require('mini.surround').setup({}) end },
  { 'echasnovski/mini.indentscope', config = function() require('mini.indentscope').setup({}) end },
  { 'echasnovski/mini.pairs',       config = function() require("mini.pairs").setup({}) end },
  { 'wakatime/vim-wakatime' },

  -- smooth scrolling
  {
    'declancm/cinnamon.nvim',
    opts = {
      extra_keymaps = true,
      extended_keymaps = true,
      scroll_limit = 20,
    },
  },

  -- pane manipulations
  { "anuvyklack/windows.nvim",
    dependencies = "anuvyklack/middleclass",
    config = function()
      require('windows').setup(
        {
          autowidth = {
            enable = false
          }
        }
      )
      require('which-key').register({ ["<leader>w"] = { name = "+[w]indow" } })
      vim.keymap.set('n', "<leader>wm", require('windows.commands').maximize, { desc = "[M]aximize" })
      vim.keymap.set('n', "<leader>we", require('windows.commands').equalize, { desc = "[E]qualize" })
      vim.keymap.set('n', "<leader>wt", require('windows.autowidth').toggle, { desc = "[E]qualize" })
    end
  },

  {
    'github/copilot.vim',
    config = function()
      vim.keymap.set('i', "<C-]>", "<Plug>(copilot-next)")
      vim.cmd [[
      let g:copilot_filetypes = {
        \ '*': v:false,
        \ 'ruby': v:true,
        \ }
      ]]
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
}
