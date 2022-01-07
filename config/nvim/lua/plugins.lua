vim.cmd [[packadd packer.nvim]]

return require("packer").startup(
  function(use)
    use {"wbthomason/packer.nvim", opt = true}
    use 'svermeulen/vimpeccable'

    use "nvim-lua/plenary.nvim"
    use "nvim-lua/popup.nvim"
    use "kyazdani42/nvim-web-devicons"

    use { 'norcalli/nvim-colorizer.lua', config = require('colorizer').setup() }

    -- theme
    use 'EdenEast/nightfox.nvim'

    -- LSP
    use "neovim/nvim-lspconfig"
    use { "onsails/lspkind-nvim", config = require("lspkind").init( { with_text = true })}
    use "nvim-lua/lsp-status.nvim"
    use { "folke/trouble.nvim", config = function() require("trouble").setup { } end }

    -- completion
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'
    use "L3MON4D3/LuaSnip"
    use 'saadparwaiz1/cmp_luasnip'
    -- use 'akinsho/toggleterm.nvim'

    use "nvim-telescope/telescope.nvim"
    use {"nvim-treesitter/nvim-treesitter", run = ':TSUpdate' }
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use {"lewis6991/gitsigns.nvim", config = require('gitsigns').setup()}
    use {'glepnir/galaxyline.nvim', branch = "main"}
    use { 'karb94/neoscroll.nvim', config = require('neoscroll').setup() }
    -- use 'blackCauldron7/surround.nvim'
    use { 'b3nj5m1n/kommentary', config =
      require('kommentary.config').configure_language("default", {
          prefer_single_line_comments = true,
      })
    }

    -- new stuff
    use 'yamatsum/nvim-cursorline'
    -- use 'pwntester/octo.nvim'
    -- use 'jose-elias-alvarez/null-ls.nvim'
    use {'alvarosevilla95/luatab.nvim', config = require('luatab').setup({})}
    use 'David-Kunz/treesitter-unit'
    use {
      "cuducos/yaml.nvim",
      ft = {"yaml"},
      config = function ()
        require("yaml_nvim").init()
      end
    }
    use {
      "AckslD/nvim-neoclip.lua",
      config = function()
        require('neoclip').setup()
      end,
    }

    -- vim
    use 'wakatime/vim-wakatime'
    use { 'AndrewRadev/splitjoin.vim'}
    use 'dyng/ctrlsf.vim'
    use 'michaeljsmith/vim-indent-object'
    use 'whiteinge/diffconflicts'
    use { 'machakann/vim-highlightedyank'}
    use 'rhysd/clever-f.vim'
    use 'tpope/vim-eunuch'
    use 'tpope/vim-surround'
    use 'tpope/vim-repeat'
    use 'vim-crystal/vim-crystal'
    use 'jidn/vim-dbml'


    -- languages
    use 'elixir-editors/vim-elixir'
    use 'slim-template/vim-slim'
    use 'glench/vim-jinja2-syntax'

    -- use 'alvan/vim-closetag'
    -- use 'svermeulen/vim-yoink'
    -- use 'wellle/targets.vim'
    -- { use 'vim-ruby/vim-ruby', config = "vim.g.ruby_indent_block_style = 'do'" }
    -- use 'tpope/vim-rails'
    -- use 'pangloss/vim-javascript'
    -- use 'amadeus/vim-mjml'
    -- use 'tbastos/vim-lua'
    use 'dstein64/vim-startuptime'
  end
)
