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

require("lazy").setup('plugins', {
  change_detection = { notify = false },
})

require "general.mappings"
require "my_plugins.extensions"
require "my_plugins.file"
