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

require("lazy").setup('plugins')

require "general.mappings"
