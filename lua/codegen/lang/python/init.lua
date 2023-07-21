local ts_parsers = require("nvim-treesitter.parsers")
local ts_queries = require("nvim-treesitter.query")

local utils = require('codegen.utils')
local template = require('codegen.template')
local PythonFile = require('codegen.lang.python.file').PythonFile


-- -- node should be a function node
-- -- returns name, block
-- function M.function_parts(node)
--   if not node then
--     return
--   end

--   local block_node, name_node
--   for child_node, name in node:iter_children() do
--     if name == 'identifier' then
--       name_node = child_node
--     end
--     if name == 'body' then
--       block_node = child_node
--     end
--   end
--   return name_node, block_node
-- end

-- function M.calls(node, calls)
--   if not calls then
--     calls = {}
--   end

--   for child_node, name in node:iter_children() do
--     if child_node:type() == 'call' then
--       table.insert(calls, child_node)
--     end
--     if child_node:child_count() then
--       M.calls(child_node, calls)
--     end
--   end
--   return calls
-- end

-- function M.save_test_node(opts)
--   if not opts then
--     opts = {}
--   end
--   local is_headless = utils.is_headless()
--   local win = utils.open_scratch_window()
--   local test_format = opts.test_format or 'pytest'

--   vim.cmd(":e " .. opts.filepath)
--   vim.cmd(":set number")
--   vim.cmd(":call cursor(" .. opts.line .. ", " .. opts.col .. ")")

--   local parser = vim.treesitter.get_parser(0)
--   local tree = unpack(parser:parse())
--   local node = tree:root():named_descendant_for_range(opts.line - 1, opts.col, opts.line - 1, opts.col)
--   local parent_function_node = M.find_parent(node, 'function_definition')
--   if not parent_function_node then
--     print("Cursor not in a function")
--     return
--   end

--   M.current_test_node = parent_function_node
--   print('Function node copied')

--   return parent_function_node
-- end

-- function M.gen_test(opts)
--   if not opts then
--     opts = {}
--   end

--   local function_node = opts.function_node or M.current_test_node

--   local name_node, block_node = M.function_parts(function_node)

--   local calls = M.calls(block_node)
--   utils.pp(calls)

--   for _, call in pairs(calls) do

--   end

--   -- vim.lsp.buf.definition()
-- end

-- function M.add_class(filepath, insert_lines, options)
--   if options.insert_after_node then
--     local line_number = utils.get_last_line(options.insert_after_node)
--     utils.insert_lines(node, insert_lines)
--   end
-- end

local Python = {}
Python.__index = Python


Python.new = function(opts)
  local defaults = {
    file_options = opts or {}
  }
  if not defaults.file_options.base_dir then
    defaults.file_options.base_dir = "."
  end
  return setmetatable(defaults, Python)
end

function Python:file(filepath, opts)
  return PythonFile.new(
    self.file_options.base_dir .. "/" .. filepath,
    vim.tbl_deep_extend("force", self.file_options, opts or {}))
end

function Python:base_dir(base_dir)
  self.file_options.base_dir = base_dir
end

return {
  Python = Python
}
