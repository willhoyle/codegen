local ts = {
  test = 2
}
local mt = {
  __index = function(tbl, key)
    print("yp yp")
    print(tbl, key)
  end
}

-- mt.__index = mt
-- function mt.__call(...)
--   print("Table called!", ...)
-- end

local t = setmetatable(ts, mt)

local test = t.test --> prints "Table called!"
-- -- ts(5) --> prints "Table called!" and 5

-- local Choice = {}
-- -- Choice.__index = Choice
-- function Choice.__call(...)
--   print("Table called!", ...)
-- end

-- local s = {}
-- setmetatable(s, Choice)

-- s(5)
--


local Choice = {
  __index = function(tbl, key)
    print(key)
    return function()
      return tbl.options
    end
  end
}

function Choice.new(opts)
  local defaults = {
    options = opts,
  }
  return setmetatable(defaults, Choice)
end

local choice = Choice.new({ test = 1 })

print(vim.inspect(choice:test()))
print(choice.options)
