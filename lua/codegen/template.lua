local lustache = require "lustache"

local M = {}


function M.render(options)
  local output = M.render_string(options)
  local lines = {}
  for line in output:gmatch("(.-)[\r\n]") do
    table.insert(lines, line)
  end

  -- Handle the last line (no newline at the end)
  local last_line = output:match(".*[\r\n](.-)$")
  table.insert(lines, last_line)

  return lines
end

function M.render_string(options)
  local template = options.template or ''
  local data = options.data or ''

  local output = lustache:render(template, data)
  return output
end

return M
