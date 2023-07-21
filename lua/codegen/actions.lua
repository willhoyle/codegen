local lib = require('codegen.lib')
local tasks = require('codegen.tasks')


local M = {}

local actions = {
  ['codegen.actions'] = function()
    local c = lib.Codegen.new()
    local action_name = c.choice:get_telescope({
      title = "Choose which action you want to run",
      choices = M.actions_list()
    })
    local action_func = M.get(action_name)

    tasks.cancel_current()
    lib.run(action_func)
  end
}

function M.register_action(name, action)
  actions[name] = action
end

function M.actions_list()
  local _actions = {}
  for action_name, _ in pairs(actions) do
    table.insert(_actions, action_name)
  end
  return _actions
end

function M.get(action)
  local action_func = actions[action]
  return action_func
end

return M
