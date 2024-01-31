local fn = vim.fn
-- local cmd = vim.cmd

-- local function setup()
--   local dir = expand("%:p:h")
--   local name = expand("%:t")
--   local nameNoExt = expand('%:r')
--   local ext = expand("%:e")
-- end

local function mkdir()
  local dir = fn.expand('%:p:h')
  fn.mkdir(dir, "p")
  vim.notify("Folder " .. dir .. " created", vim.log.levels.INFO)
end

local function save()
  local dir = fn.expand('%:p:h')
  local dirExists = fn.finddir(dir)
  if dirExists == "" then
    fn.mkdir(dir, "p")
  end

  local fullpath = fn.expand('%:p')
  vim.cmd.saveas(fullpath)

  vim.notify("File " .. fullpath .. " created", vim.log.levels.INFO)
end

local function duplicate()
  local filepath = fn.expand('%:p')

  vim.ui.input({ prompt = "Duplicate as: ", default = filepath, completion = "dir" }, function(newFilePath)
    vim.cmd.saveas(newFilePath)
    vim.cmd.edit(newFilePath)
  end)
end

local function move()
  local filepath = fn.expand('%:p')
  vim.ui.input({ prompt = "Move: ", default = filepath, completion = "dir" }, function(newFilePath)
    local dir = fn.fnamemodify(newFilePath, ':h')
    local dirExists = fn.finddir(dir)
    if dirExists == "" then
      fn.mkdir(dir, "p")
    end
    local success, errormsg = os.rename(filepath, newFilePath)
    if success then
      vim.cmd.edit(newFilePath)
      vim.notify('Moved to "' .. newFilePath .. '".')
    else
      vim.notify("Could not move file: " .. errormsg, vim.log.levels.ERROR)
    end
  end)
end

local function rename()
  local dir = fn.expand('%:p:h')
  local filepath = fn.expand('%:p')
  local oldName = fn.expand('%:t:r')
  local ext = fn.expand('%:e')
  vim.ui.input({ prompt = "Rename: ", default = oldName, completion = "dir" }, function(newName)
    local newFilePath = dir .. '/' .. newName .. '.' .. ext
    local success, errormsg = os.rename(filepath, newFilePath)
    if success then
      vim.cmd.edit(newFilePath)
      vim.notify('Renamed "' .. oldName .. '" to "' .. newName .. '".')
    else
      vim.notify("Could not rename file: " .. errormsg, vim.log.levels.ERROR)
    end
  end)
end

local function delete()
  local filepath = fn.expand('%:p')
  local success, errormsg = os.remove(filepath)
  if success then
    vim.cmd.close()
    vim.notify('Deleted "' .. filepath)
  else
    vim.notify("Could not rename file: " .. errormsg, vim.log.levels.ERROR)
  end
end

vim.keymap.set('n', "<leader>ok", mkdir, { desc = "Create dir" })
vim.keymap.set('n', "<leader>os", save, { desc = "[S]ave" })
vim.keymap.set('n', "<leader>or", rename, { desc = "[R]ename" })
vim.keymap.set('n', "<leader>om", move, { desc = "[M]ove" })
vim.keymap.set('n', "<leader>od", delete, { desc = "[D]elete file" })
vim.keymap.set('n', "<leader>oS", duplicate, { desc = "[S]ave as" })
vim.keymap.set('n', '<leader>ol', function()
  vim.api.nvim_command('let @*=expand("%") . ":" . line(".")')
end, { desc = "Copy file and [l]ine to clipboard"})
vim.keymap.set('n', '<leader>of', function()
  vim.api.nvim_command('let @*=expand("%")')
end, { desc = "Copy [f]ile to clipboard"})
