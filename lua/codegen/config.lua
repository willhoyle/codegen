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
      empty_template = "",
      empty_filetype = "markdown",
      choice_name = 'choice'
    },
    data = {},
    set_current = tasks.set_current,
    cancel_current = tasks.cancel_current,
    cancel_on_exit = false
  },
  python = {},
  data = {}
}

M.options = {}

local function set_title(opts)
  if not opts.choice then
    return
  end
  if opts.choice.special_char and not opts.choice.preview.title then
    opts.choice.preview.title = title(opts.choice.special_char)
  end
end

function M.make_options(opts)
  set_title(opts)
  return vim.tbl_deep_extend("force", M.options, opts or {})
end

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", defaults, opts or {})
end

M.setup()

return M
