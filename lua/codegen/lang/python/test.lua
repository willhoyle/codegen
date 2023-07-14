local utils = require('codegen.utils')

return {
  test = function()
    return utils.script_path()
  end
}
