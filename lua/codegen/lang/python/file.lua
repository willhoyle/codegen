local template = require("codegen.template")

local LANG = "python"


local PythonFile = {}
PythonFile.__index = PythonFile


function PythonFile.new(filepath, opts)
  local defaults = {}
  opts = opts or {}
  if not opts.bufnr then
    vim.cmd(":e " .. filepath)
    opts.bufnr = vim.api.nvim_get_current_buf()
  end
  return setmetatable(vim.tbl_deep_extend("force", defaults, opts), PythonFile)
end

local marker_query_template = [[
((comment) @comment
 (#eq? @comment "{{ marker }}"))
]]

function PythonFile:marker(marker, marker_template)
  local marker_query = template.render_string({
    template = marker_template or marker_query_template,
    data = { marker = marker },
  })
  local query = vim.treesitter.query.parse(LANG, marker_query)
  local parser = vim.treesitter.get_parser(self.bufnr, LANG)
  local tstree = parser:parse()

  for _, tree in pairs(tstree) do
    for _, node, _ in query:iter_captures(tree:root(), self.bufnr, 0, -1) do
      if node then
        return node
      end
    end
  end
end

function PythonFile:insert_after_node(node, fragment_or_lines)
  fragment_or_lines = fragment_or_lines or {}
  local row1, col1, row2, col2 = node:range()
  local lines = fragment_or_lines.lines or fragment_or_lines
  vim.api.nvim_buf_set_lines(self.bufnr, row1 + 1, row1 + 1, true, lines)
  if fragment_or_lines.imports then
    self:insert_imports(fragment_or_lines.imports)
  end
end

local import_statement_query = "(import_statement) @import_statement"
local import_from_statement_query = "(import_from_statement) @import_from_statement"


function PythonFile:insert_imports(imports)
  local import_statement_parsed = vim.treesitter.query.parse(LANG, import_statement_query)
  local import_from_statement_parsed = vim.treesitter.query.parse(LANG, import_from_statement_query)
  local parser = vim.treesitter.get_parser(self.bufnr, LANG)
  local tstree = parser:parse()

  local last_import_line = 0
  for _, tree in pairs(tstree) do
    for _, node, _ in import_statement_parsed:iter_captures(tree:root(), self.bufnr, 0, -1) do
      local _, _, row2, _ = node:range()
      if row2 > last_import_line then
        last_import_line = row2
      end
    end
    for _, node, _ in import_from_statement_parsed:iter_captures(tree:root(), self.bufnr, 0, -1) do
      local _, _, row2, _ = node:range()
      if row2 > last_import_line then
        last_import_line = row2
      end
    end
  end
  vim.api.nvim_buf_set_lines(self.bufnr, last_import_line, last_import_line, true, imports)
end

function PythonFile:append_list(node, text)
end

function PythonFile:prepend_list(node, text)
end

function PythonFile:save()
  vim.cmd(':silent !mkdir -p %:h')
  vim.cmd(":w")
end

return { PythonFile = PythonFile }
