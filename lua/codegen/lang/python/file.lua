local lustache = require("codegen.lustache")

local PythonFile = {}
PythonFile.__index = {}

function PythonFile.new(filepath, opts)
  return setmetatable(opts, PythonFile)
end

local marker_query_template = [[
((comment) @comment
 (#eq? @comment "{{ marker }}"))
]]

function PythonFile:marker(marker)
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

function PythonFile:insert_after_node(node, lines)
  local row1, col1, row2, col2 = node:range()
  print(node:range())
  vim.api.nvim_buf_set_lines(self.bufnr, row1 + 1, row1 + 1, true, lines)
end

function PythonFile:save()
  vim.cmd(":w")
end

return { PythonFile = PythonFile }