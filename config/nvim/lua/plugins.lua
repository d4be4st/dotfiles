vim.cmd [[packadd packer.nvim]]

return require("packer").startup(
  function(use)
    use {"wbthomason/packer.nvim", opt = true}
    use 'svermeulen/vimpeccable'

    use "nvim-lua/plenary.nvim"
    use "nvim-lua/popup.nvim"
    use "kyazdani42/nvim-web-devicons"

    use 'norcalli/nvim-colorizer.lua'
    use "tjdevries/colorbuddy.vim"
    use "Th3Whit3Wolf/onebuddy"
    use "neovim/nvim-lspconfig"
    use "onsails/lspkind-nvim"
    use "nvim-lua/lsp-status.nvim"
    use "hrsh7th/nvim-compe"
    use "L3MON4D3/LuaSnip"

    use "nvim-telescope/telescope.nvim"
    use {"nvim-treesitter/nvim-treesitter", run = ':TSUpdate' }
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use "lewis6991/gitsigns.nvim"
    use {'glepnir/galaxyline.nvim', branch = "main"}
    use 'karb94/neoscroll.nvim'
    use 'blackCauldron7/surround.nvim'
    use 'b3nj5m1n/kommentary'

    -- new stuff
    use "tversteeg/registers.nvim"
    use 'edluffy/specs.nvim'
    use 'yamatsum/nvim-cursorline'
    use 'windwp/nvim-spectre'

    -- vim
    use 'wakatime/vim-wakatime'
    use 'AndrewRadev/splitjoin.vim'
    use 'dyng/ctrlsf.vim'
    use 'michaeljsmith/vim-indent-object'
    use 'whiteinge/diffconflicts'
    use 'machakann/vim-highlightedyank'
    use 'rhysd/clever-f.vim'
    use 'elixir-editors/vim-elixir'

    use 'tpope/vim-eunuch'
    -- use 'alvan/vim-closetag'
    -- use 'svermeulen/vim-yoink'
    -- use 'wellle/targets.vim'
    -- use 'vim-ruby/vim-ruby'
    -- use 'tpope/vim-rails'
    -- use 'pangloss/vim-javascript'
    use 'slim-template/vim-slim'
    -- use 'amadeus/vim-mjml'
    -- use 'tbastos/vim-lua'
  end
)
