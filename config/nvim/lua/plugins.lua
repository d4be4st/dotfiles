local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "nvim-lua/plenary.nvim",
  "nvim-lua/popup.nvim",
  "kyazdani42/nvim-web-devicons",

  -- theme
  'EdenEast/nightfox.nvim',

  -- LSP
  "neovim/nvim-lspconfig",
  { "onsails/lspkind-nvim", config = function() require("lspkind").init({ mode = "symbol_text" }) end },
  "nvim-lua/lsp-status.nvim",
  "folke/trouble.nvim",
  "b0o/schemastore.nvim",

  -- completion
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/nvim-cmp',
  "L3MON4D3/LuaSnip",
  'saadparwaiz1/cmp_luasnip',

  "nvim-telescope/telescope.nvim",
  { "nvim-telescope/telescope-file-browser.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ':TSUpdate' },
  { "lewis6991/gitsigns.nvim", config = function() require('gitsigns').setup() end },
  "glepnir/galaxyline.nvim",
  { 'karb94/neoscroll.nvim', config = function() require('neoscroll').setup() end },
  { 'b3nj5m1n/kommentary', config = function()
    require('kommentary.config').configure_language("default", {
      prefer_single_line_comments = true,
    })
  end },

  -- new stuff
  "yamatsum/nvim-cursorline",
  { 'alvarosevilla95/luatab.nvim', config = function() require('luatab').setup({}) end },

  "ggandor/leap.nvim",

  { "RRethy/nvim-treesitter-endwise",
    config = function() require('nvim-treesitter.configs').setup { endwise = { enable = true } } end },
  {
    "AckslD/nvim-neoclip.lua",
    config = function()
      require('neoclip').setup()
    end,
  },
  "AndrewRadev/splitjoin.vim",
  'dyng/ctrlsf.vim',
  'michaeljsmith/vim-indent-object',
  'whiteinge/diffconflicts',
  'machakann/vim-highlightedyank',
  'rhysd/clever-f.vim',
  'tpope/vim-eunuch',
  'tpope/vim-surround',
  'tpope/vim-repeat',

  --     -- languages
  'vim-crystal/vim-crystal',
  'jidn/vim-dbml',
  -- 'elixir-editors/vim-elixir'
  'slim-template/vim-slim',
  'glench/vim-jinja2-syntax',
  'hashivim/vim-terraform',
})
