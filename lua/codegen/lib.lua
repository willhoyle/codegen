local config = require("codegen.config")
local cache = require("codegen.cache")
local lang = require("codegen.lang")
local actions = require("codegen.actions")
local choice = require("codegen.choice")
local async = require("codegen.async")


local Session = {}

function Session.new(opts)
  local options = {
    cache = opts.cache,
    choice = choice.Choice.new(opts),
    python = {
      file = function(filepath)
        return lang.Python.new({
          cache = opts.cache,
          filepath = filepath
        })
      end
    }
  }
  return setmetatable(options, Session)
end

local function run(action)
  local action_config = actions.get(action)
  if not action_config then
    return
  end

  local session_cache = cache.session_cache(action)

  local paused = false
  local pause = function()
    paused = true
  end
  local resume = function()
    run(action)
  end

  if type(action_config) == "table" then
    for i, action_func in ipairs(vim.list_slice(action_config, session_cache.current_step)) do
      if not paused then
        local session = Session.new({ cache = session_cache, pause = pause, resume = resume })
        local wrapped = async.void(action_func)
        session_cache.current_step = session_cache.current_step + 1
        wrapped(session)
      end
    end
  end

  if session_cache.current_step > #action_config then
    cache.clear(action)
    return
  end
end

return {
  Session = Session,
  run = run
}
