local ls = require('luasnip')
local s = ls.s
local t = ls.t
local i = ls.i
local f = ls.f
local iter = require('plenary.iterators')

-- utils
--
local function trim(string)
  return (string:gsub("^%s*(.-)%s*$", "%1"))
end

-- ruby
local function parse_params(args, fn)
  local variables = args[1][1]
  if variables == "" then
    return {""}
  else
    local vars = iter.split(variables, ",")
    return vars:map(function(var)
      local trimmed = trim(var)
      return fn(trimmed)
    end):tolist()
  end
end

local function r_params(args)
  return parse_params(args, function(variable)
    return "  @" .. variable .. " = " .. variable
  end)
end

local function attr_readers(args)
  return parse_params(args, function(variable)
    return "attr_reader :" .. variable
  end)
end

local function file_name()
  local path = vim.fn.expand("%:r")
  local ret = path:gsub("(%w+)", function(w) return w:sub(1,1):upper()..w:sub(2):lower() end)
  ret = ret:gsub("/", "::"):gsub("_", "")
  return {ret}
end

-- snippets

ls.add_snippets("ruby", {
  s({trig = "pry"}, {
      t({"binding.pry"})
  }),
  s({trig = "frozen"}, {
      t({"# frozen_string_literal: true", ""})
  }),
  s({trig = "defi"}, {
      f(attr_readers, {1}),
      t({"", "", "def initialize("}),
      i(1),
      t({")", ""}),
      f(r_params, {1}),
      i(0),
      t({"", "end"})
  }),
  s({trig = "cla"}, {
      t({"# frozen_string_literal: true", "", "class "}),
      f(file_name, {}),
      t({"", "  "}),
      i(0),
      t({"", "end"})
  }),
  s({trig = "mod"}, {
      t({"# frozen_string_literal: true", "", "module "}),
      f(file_name, {}),
      t({"", "  "}),
      i(0),
      t({"", "end"})
  }),
})

ls.add_snippets("slim", {
  s({trig = "pry"}, {
      t({"- binding.pry"})
  })
})

ls.add_snippets("heex", {
  s({trig = "="}, {
      t("<%= "),
      i(0),
      t(" %>")
  }),
  s({trig = "%"}, {
      t("<% "),
      i(0),
      t(" %>")
  })
})

-- Mappings
vim.keymap.set('i', '<Tab>', function() ls.jump(1) end, { silent = true })
vim.keymap.set('i', '<S-Tab>', function() ls.jump(-1) end, { silent = true })
vim.keymap.set('i', '<C-e>', function() ls.change_choice(1) end, { silent = true, expr = true})
