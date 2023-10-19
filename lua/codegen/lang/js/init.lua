local ts_parsers = require("nvim-treesitter.parsers")
local ts_queries = require("nvim-treesitter.query")

local utils = require('codegen.utils')
local template = require('codegen.template')
local JSFile = require('codegen.lang.js.file').JSFile

local JS = {}
JS.__index = JS


JS.new = function(opts)
  local defaults = {
    options = opts or {},
    base_dir = opts.base_dir or "."
  }
  return setmetatable(defaults, JS)
end


function JS:file(filepath, opts)
  self.options.filepath = filepath
  return JSFile.new(
    self.base_dir .. "/" .. template.render_string(filepath, self.options.data),
    vim.tbl_deep_extend("force", self.options, opts or {}))
end

return {
  JS = JS
}
