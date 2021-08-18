require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "javascript",
    "elixir",
    "html",
    "css",
    "scss",
    "bash",
    "json",
    "ruby",
    "scss",
    "yaml",
    "lua"
  },
  highlight = {
    enable = true,              -- false will disable the whole extension
    use_languagetree = true
  },
}
