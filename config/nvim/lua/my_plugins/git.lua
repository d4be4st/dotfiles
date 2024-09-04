local cmd = require("my_plugins.cmd")

local function git_status()
  cmd.execute_cmd({"git", "status"}, "Git status")
end

local function git_commit()
  cmd.create_input("Commit message", function(message)
    cmd.execute_cmd({"git", "commit", "-m", message}, "Git commit")
  end)
end

local function git_push()
  cmd.execute_cmd({"git", "push"}, "Git push")
end

local function git_add_all()
  cmd.execute_cmd({"git", "add", "."}, "Git add all")
end

vim.keymap.set('n', '<leader>Gs', git_status, { desc = "[S]status" })
vim.keymap.set('n', '<leader>Gc', git_commit, { desc = "[C]ommit" })
vim.keymap.set('n', '<leader>Gp', git_push, { desc = "[P]ush" })
vim.keymap.set('n', '<leader>Ga', git_add_all, { desc = "[A]dd all" })
