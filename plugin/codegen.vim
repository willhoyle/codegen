function! s:complete(arg,line,pos) abort
  return join(sort(luaeval('require("codegen.actions").actions_list()')), "\n")
endfunction

command! -nargs=? -complete=custom,s:complete Codegen lua require'codegen.commands'.codegen(<f-args>)
