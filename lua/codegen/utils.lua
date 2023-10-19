local M = {}

-- Opens a floating window with a default hidden scratch buffer
function M.open_scratch_window(bufnr)
  local width = 50
  local height = 10

  -- scratch buffer
  bufnr = bufnr ~= nil and bufnr or vim.api.nvim_create_buf(false, true)

  if M.is_headless() then
    return nil
  end

  local ui = vim.api.nvim_list_uis()[1]
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = (ui.width / 2) - (width / 2),
    row = (ui.height / 2) - (height / 2),
    anchor = 'NW',
    style = 'minimal',
  }
  local win = vim.api.nvim_open_win(bufnr, true, opts)
  return win
end

function M.is_headless()
  return #vim.api.nvim_list_uis() == 0
end

function M.pp(tbl)
  print(vim.inspect(tbl))
end

function M.close_window(win)
  if win == nil then
    return
  end

  vim.api.nvim_win_close(win, true)
end

function M.get_last_line(node)
  if not node then
    return
  end
  local start_row, start_column, end_row, end_column = node:range()
  return end_row
end

function M.insert_lines(line_number, lines)
  vim.api.nvim_buf_set_lines(0, line_number, line_number, false, lines)
end

function M.find_parent(node, node_type)
  while true do
    if not node or node:type() == node_type then
      return node
    end

    node = node:parent()
  end
end

local function is_win()
  return package.config:sub(1, 1) == '\\'
end

local function get_path_separator()
  if is_win() then
    return '\\'
  end
  return '/'
end


function M.script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  if is_win() then
    str = str:gsub('/', '\\')
  end
  return str:match('(.*' .. get_path_separator() .. ')')
end

function M.get_first_capture_by_name(name, tstree, query, bufnr)
  for _, tree in pairs(tstree) do
    for id, capture_node, metadata in query:iter_captures(tree:root(), bufnr, 0, -1) do
      local capture_name = query.captures[id] -- name of the capture in the query
      if capture_name == name then
        return capture_node
      end
    end
  end
end

function M.get_last_capture_by_name(name, tstree, query, bufnr)
  local capture = nil
  for _, tree in pairs(tstree) do
    for id, capture_node, metadata in query:iter_captures(tree:root(), bufnr, 0, -1) do
      local capture_name = query.captures[id] -- name of the capture in the query
      if capture_name == name then
        capture = capture_node
      end
    end
  end
  return capture
end

return M
