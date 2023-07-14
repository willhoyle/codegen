local M = {}

local function mock_snippet()
  return s("example4", fmt([[
  @patch("")
  repeat {a} with the same key {a}
  ]], {
    a = i(1, "this will be repeat")
  }, {
    repeat_duplicates = true
  }))
end

-- pytest snippet
function M.pytest(payload)
  local test_name = payload.test_name or 'test_name'
  local mocks = payload.mocks or {}



end

return M
