local utils = require('codegen.utils')
local base = require('codegen.lang.base')
local lustache = require('codegen.lustache')
local ts_parsers = require("nvim-treesitter.parsers")
local ts_queries = require("nvim-treesitter.query")

local lang = "python"

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

local defaults = {}

Python.new = function(options)
  vim.cmd(":e " .. options.filepath)
  local bufnr = vim.api.nvim_get_current_buf()
  return setmetatable(vim.tbl_deep_extend("force", defaults, {
    cache = options.cache,
    filepath = options.filepath,
    bufnr = bufnr
  }), Python)
end

local marker_query_template = [[
((comment) @comment
 (#eq? @comment "{{ marker }}"))
]]

function Python:marker(marker)
  local marker_query = lustache.render_string({
    template = marker_query_template,
    data = { marker = marker },
  })
  local query = vim.treesitter.query.parse(lang, marker_query)
  local parser = vim.treesitter.get_parser(self.bufnr, lang)
  local tstree = parser:parse()

  for _, tree in pairs(tstree) do
    for _, node, _ in query:iter_captures(tree:root(), self.bufnr, 0, -1) do
      if node then
        return node
      end
    end
  end
end

function Python:insert_after_node(node, lines)
  local row1, col1, row2, col2 = node:range()
  print(node:range())
  vim.api.nvim_buf_set_lines(self.bufnr, row1 + 1, row1 + 1, true, lines)
end

function Python:save()
  vim.cmd(":w")
end

return {
  Python = Python
}
