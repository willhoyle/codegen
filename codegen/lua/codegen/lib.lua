local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local previewers = require "telescope.previewers"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local state = require('telescope.actions.state')

local a = vim.api
local function get_choice(choices)
  local return_value
  local choice_func = function(choice)
    return_value = choice
  end
  local main = coroutine.wrap(function()
    vim.ui.select(choices, {
      format_item = function(item)
        return item
      end,
    }, choice_func)
  end)
  main()
  return return_value
end

local function buffer_ticks()
  local ticks = {}
  for _, buf in ipairs(a.nvim_list_bufs()) do
    ticks[#ticks + 1] = a.nvim_buf_get_changedtick(buf)
  end
  return ticks
end

local function rpc_wrapper(message_type, message)
  vim.rpcnotify(0, message_type, message)
end

local function render(options)
  local message = options.message or ''
  local data = options.data or ''

  local lustache = require "lustache"


  output = lustache:render(message, data)
  lines = {}
  for s in output:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  return lines
end

local function leaving_telescope_prompt()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if ft == "TelescopePrompt" then
    rpc_wrapper("get_choice_telescope", nil)
    vim.api.nvim_del_augroup_by_name("TelescopeLeave")
  end
end

function trim(str, trim)
  if str == '' then
    return str
  else
    local startPos = 1
    local endPos   = #str

    while (startPos < endPos and str:byte(startPos) <= 32) do
      startPos = startPos + 1
    end

    if startPos >= endPos then
      return ''
    else
      while (endPos > 0 and str:byte(endPos) <= 32) do
        endPos = endPos - 1
      end

      return str:sub(startPos, endPos)
    end
  end
end -- .function trim

local function get_choice_telescope(opts)
  local choices = opts.choices or {}
  local title = opts.title or "Choose:"
  local preview_title = opts.preview_title or "Info"
  local preview = opts.preview or ''
  local preview_filetype = opts.preview_filetype or ''
  local preview_empty = opts.preview_empty or 'Empty!!'
  local render_options = opts.render_options or {}

  local telescope_leave_augroup = vim.api.nvim_create_augroup("TelescopeLeave", { clear = true })
  vim.api.nvim_create_autocmd('WinLeave', {
    group = telescope_leave_augroup,
    pattern = "*",
    callback = leaving_telescope_prompt
  })

  local result
  --   local P = {}
  --   P.__index = P

  -- function P:new()
  --    return setmetatable(previewers.new_buffer_previewer {
  --       title = preview_title,
  --       define_preview = function (self, entry, status)
  --         local ft = vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", preview_filetype)
  --         local bufnr = vim.api.nvim_get_current_buf()
  --         local current_picker = state.get_current_picker(bufnr)
  --         local prompt = current_picker:_get_prompt()
  --         if string.sub(prompt, 1, 1) == ':' then
  --           render_options.data.choice = string.sub(prompt, 2, -1)
  --         else
  --           render_options.data.choice = entry.render
  --         end
  --         vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, render(render_options))
  --       end
  --     }, P)
  -- end

  --   function P:preview(entry, status)
  --     if not entry then
  --       if not self._empty_bufnr then
  --         self._empty_bufnr = vim.api.nvim_create_buf(false, true)
  --       end

  --       if vim.api.nvim_buf_is_valid(self._empty_bufnr) then
  --         vim.api.nvim_win_set_buf(status.preview_win, self._empty_bufnr)
  --       end
  --       return opts.preview_empty
  --     end
  --     return previewers.Previewer.preview(self, entry, status)
  --   end
  local pre = previewers.new_buffer_previewer {
    title = preview_title,
    define_preview = function(self, entry, status)
      local ft = vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", preview_filetype)
      local bufnr = vim.api.nvim_get_current_buf()
      local current_picker = state.get_current_picker(bufnr)
      local prompt = current_picker:_get_prompt()
      if string.sub(prompt, 1, 1) == ':' then
        render_options.data.choice = string.sub(prompt, 2, -1)
      else
        render_options.data.choice = entry.render
      end
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, render(render_options))
    end
  }
  local old = pre.preview
  pre.preview = function(self, entry, status)
    if not entry then
      if not self._empty_bufnr then
        self._empty_bufnr = vim.api.nvim_create_buf(false, true)
      end

      if vim.api.nvim_buf_is_valid(self._empty_bufnr) then
        vim.api.nvim_win_set_buf(status.preview_win, self._empty_bufnr)
      end

      vim.api.nvim_buf_set_lines(self._empty_bufnr, 0, -1, false,
        { '# No result found', '', '```python', 'def yo():', '    pass', '```' })
      vim.api.nvim_buf_set_option(self._empty_bufnr, "filetype", "markdown")
      return true
    end
    return old(self, entry, status)
  end


  local p = pickers.new({}, {
    prompt_title = title,
    previewer = pre,
    finder = finders.new_table {
      results = choices,
      entry_maker = function(entry)
        return {
          value = entry,
          render = entry.render,
          display = entry.display,
          ordinal = entry.display,
        }
      end
    },
    attach_mappings = function(prompt_bufnr, _)
      -- modifying what happens on selection with <CR>
      actions.select_default:replace(
        function()
          -- closing picker
          vim.api.nvim_del_augroup_by_name("TelescopeLeave")
          local bufnr = vim.api.nvim_get_current_buf()
          local current_picker = state.get_current_picker(bufnr)
          local prompt = current_picker:_get_prompt()
          actions.close(prompt_bufnr)
          -- the typically selection is table, depends on the entry maker
          -- here { [1] = "one", value = "one", ordinal = "one", display = "one" }
          -- value: original entry
          -- ordinal: for sorting, possibly transformed value
          -- display: for results list, possibly transformed value
          result = action_state.get_selected_entry()
          if not result then
            if string.sub(prompt, -1, -1) == ':' then
              rpc_wrapper("get_choice_telescope", string.sub(prompt, 1, -2))
            else
              rpc_wrapper("get_choice_telescope")
            end
          else
            rpc_wrapper("get_choice_telescope", result.value)
          end
        end
      )
      -- keep default keybindings
      return true
    end,
    sorter = conf.generic_sorter({}),
  })
  p:find()

  return result
end

-- vim.api.nvim_create_user_command('TestTest', '', {})

local function get_action_state()
  return { yo = 1 }
end

lib = {
  get_choice = get_choice,
  get_action_state = get_action_state,
  get_choice_telescope = get_choice_telescope,
  buffer_ticks = buffer_ticks,
  render = render
}
