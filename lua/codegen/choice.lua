local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local previewers = require "telescope.previewers"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local state = require('telescope.actions.state')

local lustache = require('codegen.template')
local async = require('codegen.async')


local Choice = {}
Choice.__index = Choice

function Choice.new(opts)
  local defaults = {
    options = opts
  }
  return setmetatable(defaults, Choice)
end

function Choice:get(choices)
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

function Choice:leaving_telescope_prompt()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if ft == "TelescopePrompt" then
    vim.api.nvim_del_augroup_by_name("TelescopeLeave")
  end
end

function Choice:_yes_no(name, title, callback)
  self:_get_telescope(name, { choices = { "Yes", "No" }, title = title }, function(response)
    callback(response == "Yes" or response == "y")
  end)
end

function Choice:_get_telescope(name, opts, callback)
  local choice_options = vim.tbl_deep_extend("force", self.options.choice, opts or {})
  choice_options.preview.choice_name = name

  if choice_options.cancel_on_exit_telescope then
    choice_options.cancel_current()
  else
    local cancel_func = function()
      self:get_telescope(name, opts, callback)
    end
    choice_options.set_current(cancel_func)
  end
  local telescope_leave_augroup = vim.api.nvim_create_augroup("TelescopeLeave", { clear = true })
  vim.api.nvim_create_autocmd('WinLeave', {
    group = telescope_leave_augroup,
    pattern = "*",
    callback = function() self:leaving_telescope_prompt() end
  })

  if choice_options.preview.empty_template == nil or choice_options.preview.empty_template == "" then
    choice_options.preview.empty_template = choice_options.preview.template
    choice_options.preview.empty_filetype = choice_options.preview.filetype
  end



  local result
  local pre = previewers.new_buffer_previewer {
    title = lustache.render_string(choice_options.preview.title, self.options.data),
    define_preview = function(_self, entry, status)
      vim.api.nvim_buf_set_option(_self.state.bufnr, "filetype", choice_options.preview.filetype)
      local bufnr = vim.api.nvim_get_current_buf()
      local current_picker = state.get_current_picker(bufnr)
      local prompt = current_picker:_get_prompt()
      if string.sub(prompt, -1, -1) == choice_options.special_char then
        self.options.data[choice_options.preview.choice_name] = string.sub(prompt, 1, -2)
      else
        self.options.data[choice_options.preview.choice_name] = entry.choice
      end

      vim.api.nvim_buf_set_lines(_self.state.bufnr, 0, -1, false, lustache.render(
        choice_options.preview.template,
        self.options.data
      ))
    end
  }
  local old = pre.preview
  pre.preview = function(_self, entry, status)
    if not entry then
      if not _self._empty_bufnr then
        _self._empty_bufnr = vim.api.nvim_create_buf(false, true)
      end

      if vim.api.nvim_buf_is_valid(_self._empty_bufnr) then
        vim.api.nvim_win_set_buf(status.preview_win, _self._empty_bufnr)
      end

      if choice_options.preview.empty_template then
        local bufnr = vim.api.nvim_get_current_buf()
        local current_picker = state.get_current_picker(bufnr)
        local prompt = current_picker:_get_prompt()

        if string.sub(prompt, -1, -1) == choice_options.special_char then
          self.options.data[choice_options.preview.choice_name] = string.sub(prompt, 1, -2)
        else
          self.options.data[choice_options.preview.choice_name] = prompt
        end

        vim.api.nvim_buf_set_option(_self._empty_bufnr, "filetype", choice_options.preview.empty_filetype)
        vim.api.nvim_buf_set_lines(_self._empty_bufnr, 0, -1, false,
          lustache.render(
            choice_options.preview.empty_template,
            self.options.data
          ))
      end
      return true
    end
    return old(_self, entry, status)
  end


  local p = pickers.new({}, {
    prompt_title = choice_options.title,
    previewer = pre,
    finder = finders.new_table {
      results = choice_options.choices,
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
          local override_char_is_present = string.sub(prompt, -1, -1) == choice_options.special_char
          if prompt and (not result or override_char_is_present) then
            local v = override_char_is_present and string.sub(prompt, 1, -2) or prompt
            if callback then
              vim.schedule(function()
                self.options.data[name] = v
                callback(v)
              end)
            end
          else
            if callback then
              vim.schedule(function()
                self.options.data[name] = result.value.value
                callback(result.value.value)
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
Choice.yes_no = async.wrap(Choice._yes_no, 4)
Choice.__call = async.wrap(Choice._get_telescope, 4)

return {
  Choice = Choice
}
