local lustache = require "lustache"

local M = {}


function M.render(options)
  local output = M.render_string(options)
  local lines = {}
  for s in output:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  return lines
end

function M.render_string(options)
  local template = options.template or ''
  local data = options.data or ''

  local output = lustache:render(template, data)
  return output
end

return M
