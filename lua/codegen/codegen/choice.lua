local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local previewers = require "telescope.previewers"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local state = require('telescope.actions.state')

local lustache = require('codegen.lustache')
local async = require('codegen.async')


local Choice = {}
Choice.__index = Choice

function Choice.new(opts)
  local options = {
  }
  return setmetatable(options, Choice)
end

function Choice:get(name, choices)
  local return_value
  local choice_func = function(choice)
    return_value = choice
  end
  vim.ui.select(choices, {
    format_item = function(item)
      return item
    end,
  }, choice_func)
  return return_value
end

function Choice:leaving_telescope_prompt(name, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if ft == "TelescopePrompt" then
    vim.api.nvim_del_augroup_by_name("TelescopeLeave")
    if callback then
      vim.schedule(function()
        callback(nil)
      end)
    end
  end
end

function Choice:_get_telescope(name, opts, callback)
  local choices = opts.choices or {}
  local title = opts.title or "Choose:"

  if not opts.preview then
    opts.preview = {}
  end
  local preview = {
    title = opts.preview.title or "Info",
    filetype = opts.preview.filetype or 'markdown',
    template = opts.preview.template,
    empty_template = opts.preview.empty_template or opts.preview.template,
    empty_filetype = opts.preview.empty_filetype or opts.preview.filetype,
    data = opts.preview.data or {}
  }
  local render_options = opts.render_options or { data = {} }

  local telescope_leave_augroup = vim.api.nvim_create_augroup("TelescopeLeave", { clear = true })
  vim.api.nvim_create_autocmd('WinLeave', {
    group = telescope_leave_augroup,
    pattern = "*",
    callback = function() self:leaving_telescope_prompt(name, callback) end
  })


  local result
  local pre = previewers.new_buffer_previewer {
    title = preview.title,
    define_preview = function(_self, entry, status)
      vim.api.nvim_buf_set_option(_self.state.bufnr, "filetype", preview.filetype)
      local bufnr = vim.api.nvim_get_current_buf()
      local current_picker = state.get_current_picker(bufnr)
      local prompt = current_picker:_get_prompt()
      if string.sub(prompt, -1, -1) == ':' then
        preview.data[name] = string.sub(prompt, 1, -2)
      else
        preview.data[name] = entry.choice
      end
      vim.api.nvim_buf_set_lines(_self.state.bufnr, 0, -1, false, lustache.render(
        {
          template = preview.template,
          data = preview.data or {}
        }))
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

      if preview.empty_template then
        local bufnr = vim.api.nvim_get_current_buf()
        local current_picker = state.get_current_picker(bufnr)
        local prompt = current_picker:_get_prompt()
        preview.data[name] = prompt
        vim.api.nvim_buf_set_option(self._empty_bufnr, "filetype", preview.empty_filetype)
        vim.api.nvim_buf_set_lines(self._empty_bufnr, 0, -1, false,
          lustache.render({
            template = preview.empty_template,
            data = preview.data or {}
          }))
      end
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
        if type(entry) ~= "table" then
          entry = {
            value = entry,
            display = entry,
          }
        end
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.display,
          choice = entry.value
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
          local override_char_is_present = string.sub(prompt, -1, -1) == ':'
          if not result or override_char_is_present then
            local v = override_char_is_present and string.sub(prompt, 1, -2) or prompt
            if callback then
              vim.schedule(function()
                callback(v)
              end)
            end
          else
            if callback then
              vim.schedule(function()
                callback(result.value.choice)
              end)
            end
          end
        end
      )
      -- keep default keybindings
      return true
    end,
    sorter = conf.generic_sorter({}),
  })
  p:find()
end

Choice.get_telescope = async.wrap(Choice._get_telescope, 4)

return {
  Choice = Choice
}
