local M = {}

local tasks = {
  current = nil
}

function M.cancel_current()
  tasks.current = nil
end

function M.set_current(callback)
  tasks.current = callback
end

function M.get_current()
  return tasks.current
end

return M
