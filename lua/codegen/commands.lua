local lib = require('codegen.lib')


local M = {
  codegen = function(action)
    lib.run(action)
  end
}

return M
