local M = {}

function M.create_input(label, submit_fn)
  local NuiText = require("nui.text")
  local Input = require("nui.input")
  local event = require("nui.utils.autocmd").event

  local prompt = NuiText("> ", "TelescopePromptPrefix")

  local input = Input({
    position = "50%",
    relative = "editor",
    size = {
      width = "50%",
    },
    border = {
      style = "rounded",
      text = {
        top = label,
        top_align = "center",
      },
    },
  }, {
    prompt = prompt,
    on_submit = function(value)
      submit_fn(value)
    end,
  })

  -- mount/open the component
  input:mount()

  -- unmount component when cursor leaves buffer
  input:on(event.BufLeave, function()
    input:unmount()
  end)
end

function M.create_popup()
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

  local popup = Popup({
    enter = true,
    relative = "editor",
    focusable = false,
    border = {
      style = "rounded",
      text = {
        top = M._label
      }
    },
    position = "50%",
    size = {
      width = "50%",
      height = "50%",
    },
  })

  popup:mount()

  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  M._popup = popup
  M._channel_id = vim.api.nvim_open_term(popup.bufnr, {})
end

function M.print_stdout(_, data)
  vim.api.nvim_chan_send(M._channel_id,  table.concat(data, "\n"))
end

function M.print_status(_, exit_code)
  if exit_code > 0 then
    M._popup.border:set_text('top', M._label .. " ✖")
  else
    M._popup.border:set_text('top', M._label .. " ✓")
  end
end

function M.execute_cmd(cmd, label)
  M._label = label
  M._cmd = cmd
  M.create_popup()

  vim.fn.jobstart(M._cmd, {
    pty = true,
    stdout_buffered = false,
    on_stdout = M.print_stdout,
    on_exit = M.print_status,
  })
end

return M
