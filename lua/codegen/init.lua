local actions = require("codegen.actions")
local lib = require("codegen.lib")


return {
  run = lib.Codegen.run,
  register_action = actions.register_action,
  Codegen = lib.Codegen
}
