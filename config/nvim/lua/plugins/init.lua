vim.cmd [[packadd packer.nvim]]

return require("packer").startup(
  function(use)
		use {"wbthomason/packer.nvim", opt = true}
		use 'svermeulen/vimpeccable'

		use "nvim-lua/plenary.nvim"
		use "nvim-lua/popup.nvim"

		use "tjdevries/colorbuddy.vim"
		use "Th3Whit3Wolf/onebuddy"
		use "neovim/nvim-lspconfig"
		use "onsails/lspkind-nvim"
		use "hrsh7th/nvim-compe"

		use {"lukas-reineke/indent-blankline.nvim", branch = "lua"}
		use "nvim-telescope/telescope.nvim"
		use "nvim-treesitter/nvim-treesitter"

		--use "kyazdani42/nvim-web-devicons"
		--use "akinsho/nvim-bufferline.lua"
		-- use "kyazdani42/nvim-tree.lua"
		-- use "lewis6991/gitsigns.nvim"
		--         use "glepnir/galaxyline.nvim"
		--         use "907th/vim-auto-save"
		--         use "norcalli/nvim-colorizer.lua"
		--         use "ryanoasis/vim-devicons"
		--         use "sbdchd/neoformat"
		--         use "windwp/nvim-autopairs"
		--         use "alvan/vim-closetag"
		--         use "tweekmonster/startuptime.vim"
		--         use "nvim-telescope/telescope-media-files.nvim"
		--         use "karb94/neoscroll.nvim"

		-- use "nekonako/xresources-nvim"

    end
)
