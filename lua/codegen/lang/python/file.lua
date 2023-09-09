local template = require("codegen.template")
local utils = require('codegen.utils')

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
  self:save()
  if fragment_or_lines.imports then
    self:insert_imports(fragment_or_lines.imports)
  end
end

function PythonFile:insert(fragment_or_tbl)
  fragment_or_tbl = fragment_or_tbl or {}
  local lines = fragment_or_tbl.lines or fragment_or_tbl
  vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, true, lines)
  self:save()
  if fragment_or_tbl.imports then
    self:insert_imports(fragment_or_tbl.imports)
  end
end

function PythonFile:insert_lines_precise(lines, row, col, indent, prepend_newline)
  print(row, col)
  print(indent)
  indent = indent or 0
  local indented_lines = {}
  for index, line in ipairs(lines) do
    table.insert(indented_lines, string.rep(" ", indent) .. line)
  end
  if prepend_newline then
    table.insert(indented_lines, 1, "")
  end
  vim.api.nvim_buf_set_text(self.bufnr, row, col, row, col, indented_lines)
  self:save()
end

local import_statement_query = "(import_statement) @import_statement"
local import_statement_parsed = vim.treesitter.query.parse(LANG, import_statement_query)

local import_from_statement_query = "(import_from_statement) @import_from_statement"
local import_from_statement_parsed = vim.treesitter.query.parse(LANG, import_from_statement_query)

function PythonFile:tstree()
  local parser = vim.treesitter.get_parser(self.bufnr, LANG)
  local tstree = parser:parse()
  return tstree
end

function PythonFile:insert_imports(imports)
  local tstree = self:tstree()
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
  self:save()
end

local list_query_template =
'((expression_statement (assignment (identifier) @list_name (#eq? @list_name "{{ list_name }}") (list) @list_node)))'

function PythonFile:list_append(list_name, text)
  local list_query = template.render_string(
    list_query_template,
    { list_name = list_name }
  )
  local list_query_parsed = vim.treesitter.query.parse(LANG, list_query)
  local list_node = utils.get_first_capture_by_name("list_node", self:tstree(), list_query_parsed, self.bufnr)
  local row1, col1, row2, col2 = list_node:range()
  self:insert_lines_precise({ text }, row2, col2 - 1, true)
end

function PythonFile:list_prepend(list_name, text)
  local list_query = template.render_string(
    list_query_template,
    { list_name = list_name }
  )
  local list_query_parsed = vim.treesitter.query.parse(LANG, list_query)
  local list_node = utils.get_first_capture_by_name("list_node", self:tstree(), list_query_parsed, self.bufnr)
  local row1, col1, row2, col2 = list_node:range()
  self:insert_lines_precise({ text }, row1, col1 + 1, true)
end

function PythonFile:last_class_variable(class_name)
  local class_variable_template =
  '((class_definition (identifier) @class_name (#eq? @class_name "{{ class_name }}") (block (expression_statement (assignment) @class_variable))))'
  local class_variable_query = template.render_string(
    class_variable_template,
    { class_name = class_name }
  )
  local class_variable_parsed = vim.treesitter.query.parse(LANG, class_variable_query)
  return utils.get_last_capture_by_name("class_variable", self:tstree(), class_variable_parsed, self.bufnr)
end

function PythonFile:class_identifier(class_name)
  local class_identifier_template =
  '((class_definition (identifier) @class_name (#eq? @class_name "{{ class_name }}")))'
  local class_identifier_query = template.render_string(
    class_identifier_template,
    { class_name = class_name }
  )
  local class_identifier_parsed = vim.treesitter.query.parse(LANG, class_identifier_query)
  return utils.get_last_capture_by_name("class_name", self:tstree(), class_identifier_parsed, self.bufnr)
end

function PythonFile:class_block(class_name)
  local class_block_template =
  '((class_definition (block (class_definition (identifier) @class_name (#eq? @class_name "{{ class_name }}") (block) @class_block (#eq? @class_name "{{ class_name }}")))))'
  local class_block_query = template.render_string(
    class_block_template,
    { class_name = class_name }
  )
  local class_block_parsed = vim.treesitter.query.parse(LANG, class_block_query)
  return utils.get_first_capture_by_name("class_block", self:tstree(), class_block_parsed, self.bufnr)
end

function PythonFile:class_variable_append(class_name, lines_or_text)
  local last_class_variable = self:last_class_variable(class_name)

  if not last_class_variable then
    local class_identifier = self:class_identifier(class_name)
    local class_block = self:class_block(class_name)
    print(class_block:range())
    if not class_identifier or not class_block then
      return
    end
    last_class_variable = {
      range = function()
        -- we assume the class is defined as class ClassName:
        -- that's why we do col2 + 1
        local row1, _, _, col2 = class_identifier:range()
        local r1, col1, _, _ = class_block:range()
        print(r1, col1)
        -- we use the col1 from the class_block since it will properly
        -- convey how many spaces we need to put (so we can support classes
        -- defined at any level)
        -- we add indent
        return row1, col1, 0, col2 + 1
      end
    }
  end
  local row1, col1, row2, col2 = last_class_variable:range()
  local lines = lines_or_text
  if type(lines_or_text) == "string" then
    lines = { lines_or_text }
    print(class_name)
    print(row1, col2, col1)
    self:insert_lines_precise(lines, row1, col2, col1, true)
  else
    print(class_name)
    print(row1, col2, col1)
    self:insert_lines_precise(lines, row1, col2, col1, true)
  end
end

function PythonFile:save()
  vim.cmd(':silent !mkdir -p %:h')
  vim.cmd(":silent w")
end

return { PythonFile = PythonFile }
