local function append_runtimepath(path)
  vim.cmd('set runtimepath^=' .. path)
end


bootstrap = {append_runtimepath=append_runtimepath}
