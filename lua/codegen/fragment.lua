local template = require "codegen.template"

local Fragment = {}
Fragment.__index = Fragment

local function render_imports(imports, data)
  local rendered_imports = {}
  for index, value in ipairs(imports) do
    table.insert(rendered_imports, template.render_string(value, data))
  end
  return rendered_imports
end

function Fragment.new(template_str, opts)
  opts = opts or {}
  local defaults = {
    lines = template.render(template_str, opts.data or {}),
    template = template_str,
    imports = render_imports(opts.imports or {}, opts.data or {})
  }
  return setmetatable(defaults, Fragment)
end

return Fragment
