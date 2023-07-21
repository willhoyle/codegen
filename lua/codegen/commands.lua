local lib     = require('codegen.lib')
local actions = require('codegen.actions')
local tasks   = require('codegen.tasks')


local M = {
  codegen = function(action_name)
    local action_func = actions.get(action_name)
    if not action_func then
      return
    end
    lib.run(action_func)
  end,
  codegen_cancel = tasks.cancel_current
}

return M
