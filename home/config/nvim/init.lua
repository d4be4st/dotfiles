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

 -- user <space> as leader, needs to happen before plugis are required
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require "general.settings"

-- ponytail: barebones by default; NVIM_FULL=1 loads every plugin.
-- Uses lazy's own defaults.cond, so gated plugins stay installed, just inert.
-- NOTE: don't run `:Lazy clean` while gated -- it will offer to delete them all.
local minimal = {
  "snacks.nvim", "which-key.nvim", "catppuccin", "lualine.nvim",
  "nvim-treesitter", "nvim-treesitter-textobjects", "nvim-treesitter-endwise",
  "nvim-web-devicons", "plenary.nvim", "nui.nvim",
  "gitsigns", "review.nvim", "codediff.nvim",
  "noice.nvim", "nvim-notify", "mini.indentscope",
  "treesj", "grug-far.nvim", "mini.surround", "flash.nvim",
}
local keep = {}
for _, n in ipairs(minimal) do keep[n] = true end

require("lazy").setup('plugins', {
  change_detection = { notify = false },
  defaults = {
    cond = vim.env.NVIM_FULL == "1" or function(p) return keep[p.name] == true end,
  },
})

require "general.mappings"
require "my_plugins.extensions"

if vim.env.NVIM_FULL == "1" then
  require "my_plugins.file"
end
