local lustache = require "lustache"

local M = {}


function M.render(template, data, indent)
  if indent == nil then
    indent = 0
  end

  data = data or {}
  local output = M.render_string(template, data)
  local lines = {}
  for line in output:gmatch("(.-)[\r\n]") do
    table.insert(lines, string.rep(" ", indent) .. line)
  end

  -- Handle the last line (no newline at the end)
  local last_line = output:match(".*[\r\n](.-)$")
  if last_line then
    table.insert(lines, last_line)
  end

  if #lines == 0 then
    table.insert(lines, output)
  end

  print(vim.inspect(lines))
  return lines
end

function M.render_string(template, data)
  data = data or {}
  -- print(vim.inspect(data))
  local output = lustache:render(template, data)
  return output
end

return M
