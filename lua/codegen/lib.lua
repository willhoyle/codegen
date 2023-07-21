local config = require("codegen.config")
local choice = require("codegen.choice")
local async = require("codegen.async")
local lang = require('codegen.lang')
local tasks = require('codegen.tasks')


local Codegen = {}

function Codegen.new(opts)
  opts = opts or {}
  local options = {
    choice = choice.Choice.new(config.make_choice_options(opts.options or {})),
    python = lang.Python.new(config.make_python_options(opts.options or {})),
    wait_for_resume = async.wrap(function(callback)
      tasks.set_current(callback)
    end, 1)
  }
  return setmetatable(options, Codegen)
end

local function run(func)
  local current_task = tasks.get_current()
  if current_task then
    -- resume last task
    current_task()
    return
  end
  async.void(
    function()
      func()
      tasks.cancel_current()
    end)()
end

return {
  Codegen = Codegen,
  run = run
}
