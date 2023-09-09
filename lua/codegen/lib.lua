local config = require("codegen.config")
local choice = require("codegen.choice")
local async = require("codegen.async")
local lang = require('codegen.lang')
local tasks = require('codegen.tasks')


local Codegen = {}

function Codegen.new(opts)
  local merged_options = config.make_options(opts or {})
  local options = {
    options = merged_options,
    data = merged_options.data,
    choice = choice.Choice.new(merged_options),
    python = lang.Python.new(merged_options),
    wait = async.wrap(function(callback)
      tasks.set_current(callback, merged_options)
    end, 1),
  }
  return setmetatable(options, Codegen)
end

local function run(func, opts)
  local current_task = tasks.get_current()
  if current_task then
    -- resume last task
    current_task.callback(current_task.opts)
    return
  end
  async.void(
    function()
      func(config.make_options({}))
      tasks.cancel_current()
    end)()
end

return {
  Codegen = Codegen,
  run = run
}
