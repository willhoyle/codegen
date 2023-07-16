local config = require("codegen.config")
local choice = require("codegen.choice")
local async = require("codegen.async")
local lang = require('codegen.lang')


local Codegen = {}

local resume = {
  current = nil
}

function Codegen.new(opts)
  local options = {
    choice = choice.Choice.new(config.make_choice_options(opts.options or {})),
    python = lang.Python.new(config.make_python_options(opts.options or {})),
    wait_for_resume = async.wrap(function(callback)
      resume.current = callback
    end, 1)
  }
  return setmetatable(options, Codegen)
end

local function run(func)
  if resume.current then
    resume.current()
    resume.current = nil
    -- vim.schedule(function()
    -- end)
    return
  end
  local wrapped = async.void(func)
  wrapped()
end

return {
  Codegen = Codegen,
  run = run
}
