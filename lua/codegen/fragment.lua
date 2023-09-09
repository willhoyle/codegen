local template = require "codegen.template"

local Fragment = {}
Fragment.__index = Fragment

function Fragment.new(template_str, opts)
  opts = opts or {}
  local defaults = {
    lines = template.render(template_str, opts.data or {}),
    template = template_str,
    imports = opts.imports or {}
  }
  return setmetatable(defaults, Fragment)
end

return Fragment
