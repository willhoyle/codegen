local M = {}

M.__index = M


M.new = function(options)
  return setmetatable(vim.tbl_deep_extend("force", defaults, {
    cache = options.cache
  }), M)
end

return M
