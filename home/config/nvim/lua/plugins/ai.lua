return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        provider = "native",
      },
      diff_opts = {
        open_in_new_tab = true,
        hide_terminal_in_new_tab = true,
      },
    },
    config = function(_, opts)
      require("claudecode").setup(opts)

      local function find_claude_buf()
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == "terminal" then
            if vim.api.nvim_buf_get_name(b):find("claude", 1, true) then
              return b
            end
          end
        end
      end

      local function toggle_claude_tab()
        local buf = find_claude_buf()
        if buf then
          local tabs = vim.api.nvim_list_tabpages()
          for _, tab in ipairs(tabs) do
            for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
              if vim.api.nvim_win_get_buf(w) == buf then
                vim.api.nvim_set_current_tabpage(tab)
                vim.api.nvim_set_current_win(w)
                vim.cmd("startinsert")
                return
              end
            end
          end
        end
        vim.cmd("0tabnew")
        vim.cmd("ClaudeCode")
        vim.schedule(function()
          for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local b = vim.api.nvim_win_get_buf(w)
            if vim.bo[b].buftype ~= "terminal" then
              pcall(vim.api.nvim_win_close, w, true)
            end
          end
        end)
      end

      vim.keymap.set("n", "<leader>cc", toggle_claude_tab, { desc = "Toggle Claude (tab)" })
    end,
    keys = {
      { "<leader>c",  nil,                              desc = "AI/Claude Code" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
      { "<leader>cr", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
      { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>cD", "<cmd>ClaudeCode --dangerously-skip-permissions<cr>", desc = "Claude (skip permissions)" },
      { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
      {
        "<leader>cs",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
    },
  }
}
