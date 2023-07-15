local config = require("codegen.config")
local choice = require("codegen.choice")
local async = require("codegen.async")
local lang = require('codegen.lang')


local Codegen = {}

function Codegen.new(opts)
  config.set_title(opts)

  local options = {
    choice = choice.Choice.new(config.make_choice_options(opts)),
    python = lang.python.Python.new(config.make_python_options(opts))
  }
  return setmetatable(options, Session)
end

local function run(func)
  local wrapped = async.void(func)
  wrapped()
end

return {
  Session = Codegen,
  run = run
}
