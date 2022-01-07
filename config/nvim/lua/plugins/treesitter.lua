require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash",
    "crystal",
    "css",
    -- "elixir",
    "html",
    "javascript",
    "json",
    "lua",
    "ruby",
    "scss",
    "scss",
    "yaml",
  },
  highlight = {
    enable = true,              -- false will disable the whole extension
    use_languagetree = true
  }
}

vim.api.nvim_set_keymap('x', 'iu', ':lua require"treesitter-unit".select()<CR>', {noremap=true})
vim.api.nvim_set_keymap('x', 'au', ':lua require"treesitter-unit".select(true)<CR>', {noremap=true})
vim.api.nvim_set_keymap('o', 'iu', ':<c-u>lua require"treesitter-unit".select()<CR>', {noremap=true})
vim.api.nvim_set_keymap('o', 'au', ':<c-u>lua require"treesitter-unit".select(true)<CR>', {noremap=true})
