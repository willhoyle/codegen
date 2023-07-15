local lib = require('codegen.lib')
local actions = require('codegen.actions')


local M = {
  codegen = function(action_name)
    local action_func = actions.get(action_name)
    if not action_func then
      return
    end
    lib.run(action_func)
  end
}

return M
