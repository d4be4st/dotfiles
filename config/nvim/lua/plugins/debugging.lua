return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      'suketa/nvim-dap-ruby',
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      require('dap-ruby').setup()

      local dap, dapui = require("dap"), require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized.dapui_config = dapui.open
      dap.listeners.before.attach.dapui_config = dapui.open
      dap.listeners.before.launch.dapui_config = dapui.open
      dap.listeners.before.event_terminated.dapui_config = dapui.close
      dap.listeners.before.event_exited.dapui_config = dapui.close

      require('which-key').register({ ["<leader>d"] = { name = "+[d]ebug" } })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle [B]reakpoint" })
      vim.keymap.set('n', '<Leader>dB', function () dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Set Conditional [Breakpoint]"})
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Start/[C]ontinue" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step [I]nto" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run [L]ast" })
      vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step [O]ut" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open [R]EPL" })
      vim.keymap.set("n", "<leader>dv", dap.step_over, { desc = "Step O[v]er" })
      vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "[X] Terminate" })

      vim.keymap.set("n", "<leader>dC", dapui.close, { desc = "DAP UI: [C]lose" })
      vim.keymap.set("n", "<leader>dO", dapui.open, { desc = "DAP UI: [O]pen" })
      vim.keymap.set("n", "<leader>dT", dapui.toggle, { desc = "DAP UI: [T]oggle" })

      local widgets = require("dap.ui.widgets")
      local function show(what)
        return function()
          widgets.centered_float(widgets[what])
        end
      end
      vim.keymap.set("n", "<leader>dh", widgets.hover, { desc = "[H]over" })
      vim.keymap.set("n", "<leader>dp", widgets.preview, { desc = "[P]review" })
      vim.keymap.set("n", "<leader>df", show("frames"), { desc = "[F]rames" })
      vim.keymap.set("n", "<leader>ds", show("scopes"), { desc = "[S]copes" })
    end
  }
}
