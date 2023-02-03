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
  { 'EdenEast/nightfox.nvim', config = function()
    require('nightfox').setup({
      options = {
        styles = {
          comments = "italic",
          keywords = "bold",
          types = "italic,bold",
        }
      }
    })
  end },
  { "catppuccin/nvim", name = "catppuccin" },

  -- Which key
  {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
      require("which-key").setup({
        plugins = {
          registers = false
        }
      })
    end,
  },

  -- Commenting
  { 'echasnovski/mini.comment', version = false, config = function() require('mini.comment').setup({}) end },

  -- -- LSP
  "neovim/nvim-lspconfig",
  { "onsails/lspkind-nvim", config = function() require("lspkind").init({ mode = "symbol_text" }) end },
  { "glepnir/lspsaga.nvim", event = "BufRead", config = function()
    require("lspsaga").setup(
      {
        lightbulb = {
          virtual_text = false,
        }
      }
    )
  end },
  { "j-hui/fidget.nvim", config = function() require("fidget").setup() end },
  { "williamboman/mason.nvim", config = function() require("mason").setup() end },
  { "williamboman/mason-lspconfig.nvim", config = function() require("mason-lspconfig").setup() end },

  -- completion
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/nvim-cmp',
  "L3MON4D3/LuaSnip",
  'saadparwaiz1/cmp_luasnip',

  -- telescope
  "nvim-telescope/telescope.nvim",
  { "nvim-telescope/telescope-file-browser.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ':TSUpdate' },

  -- other
  {
    'echasnovski/mini.surround',
    config = function() require("mini.surround").setup({}) end
  },
  { "lewis6991/gitsigns.nvim", config = function() require('gitsigns').setup() end },
  { 'declancm/cinnamon.nvim', config = function() require('cinnamon').setup({
      extra_keymaps = true,
      extended_keymaps = true
    })
  end },
  -- "glepnir/galaxyline.nvim",

  "b0o/schemastore.nvim",
  { 'echasnovski/mini.indentscope', version = false, config = function() require('mini.indentscope').setup() end },
  {
    "folke/noice.nvim",
    config = function()
      require("noice").setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        }
      })
    end,
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    }
  },
  { 'feline-nvim/feline.nvim', config = function() 
    local ctp_feline = require('catppuccin.groups.integrations.feline')

    ctp_feline.setup({})

    require("feline").setup({
        components = ctp_feline.get(),
    })
  end },
  -- "yamatsum/nvim-cursorline",
  { 'alvarosevilla95/luatab.nvim', config = function() require('luatab').setup({}) end },

  -- "ggandor/leap.nvim",

  -- { "RRethy/nvim-treesitter-endwise",
  --   config = function() require('nvim-treesitter.configs').setup { endwise = { enable = true } } end },
  -- {
  --   "AckslD/nvim-neoclip.lua",
  --   config = function()
  --     require('neoclip').setup()
  --   end,
  -- },
  -- "AndrewRadev/splitjoin.vim",
  -- 'dyng/ctrlsf.vim',
  -- 'michaeljsmith/vim-indent-object',
  -- 'whiteinge/diffconflicts',
  -- 'rhysd/clever-f.vim',
  -- 'tpope/vim-eunuch',
  -- 'tpope/vim-surround',
  -- 'tpope/vim-repeat',

  -- --     -- languages
  -- 'vim-crystal/vim-crystal',
  -- 'jidn/vim-dbml',
  -- -- 'elixir-editors/vim-elixir'
  -- 'slim-template/vim-slim',
  -- 'glench/vim-jinja2-syntax',
  -- 'hashivim/vim-terraform',
})
