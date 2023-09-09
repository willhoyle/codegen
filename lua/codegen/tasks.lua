local M = {}

local tasks = {
  current = nil
}

function M.cancel_current()
  tasks.current = nil
end

function M.set_current(callback, options)
  tasks.current = {
    callback = callback,
    options = options
  }
end

function M.get_current()
  return tasks.current
end

return M
