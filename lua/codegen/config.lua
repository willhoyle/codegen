local tasks = require "codegen.tasks"
local M = {}

local default_special_char = "@"

local function title(special_char)
  return "Select from list or Enter prompt + " .. special_char .. " (e.g. my_prompt" .. special_char .. ")"
end

local defaults = {
  choice = {
    special_char = default_special_char,
    title = title(default_special_char),
    choices = {},
    preview = {
      title = "Info",
      template = "",
      filetype = "markdown",
      empty_template = nil,
      empty_filetype = nil,
      choice_name = 'choice'
    },
    data = {},
    set_current = tasks.set_current,
    cancel_current = tasks.cancel_current,
    cancel_on_exit = false
  },
  python = {}
}

M.options = {}

local function set_title(opts)
  if opts.special_char and not opts.preview.title then
    opts.preview.title = title(opts.special_char)
  end
end

function M.make_choice_options(opts)
  set_title(opts.choice or {})
  return vim.tbl_deep_extend("force", M.options.choice, opts.choice or {})
end

function M.make_python_options(opts)
  return vim.tbl_deep_extend("force", M.options.python, opts.python or {})
end

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", defaults, opts or {})
end

M.setup()

return M
