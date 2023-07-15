local config = require("codegen.config")
local choice = require("codegen.choice")
local async = require("codegen.async")
local lang = require('codegen.lang')


local Codegen = {}

function Codegen.new(opts)
  local options = {
    choice = choice.Choice.new(config.make_choice_options(opts.options or {})),
    python = lang.Python.new(config.make_python_options(opts.options or {})),
    pause = function() coroutine.yield() end
  }
  return setmetatable(options, Codegen)
end

local function run(func)
  local wrapped = async.void(func)
  wrapped()
  print("out hereeeeee")
end

return {
  Codegen = Codegen,
  run = run
}
