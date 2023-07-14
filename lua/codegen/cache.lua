local M = {}

local state = {}

function M.session_cache(action)
  if not state[action] then
    state[action] = {
      current_step = 1
    }
  end

  return state[action]
end

function M.clear(action)
  state[action] = nil
end

return M
