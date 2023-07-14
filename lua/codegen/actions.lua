local M = {}

local actions = {}

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
  local action_config = actions[action]
  return action_config
end

return M
