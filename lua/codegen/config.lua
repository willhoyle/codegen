local M = {}

local special_char = "@"

local function title(special_char)
  return "Select from list or Enter prompt + " .. special_char .. " e.g. my_prompt" .. special_char
end

local defaults = {
  choice = {
    special_char = special_char,
    preview = {
      title = title(special_char),
      choices = {},
      preview = {
        title = "Info",
        template = "",
        filetype = "markdown",
        empty_template = "",
        empty_filetype = "markdown",
      }
    }
  }
  python = {}
}

M.options = {}

local function set_title(opts)
  if opts.special_char and not opts.preview.title then
    opts.preview.title = title(opts.special_char)
  end
end

function M.make_choice_options(opts)
  set_title(opts)
  return vim.tbl_deep_extend("force", M.options.choice, opts.options.choice)
end

function M.make_python_options(opts)
  return vim.tbl_deep_extend("force", M.options.python, opts.options.python)
end

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

M.setup()

return M
