local telescope = require("telescope.builtin")
local context = require("agripa.context")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

function M.toggle_context()
	telescope.find_files({
		attach_mappings = function(prompt_bufnr, map)
			-- Toggle file context on TAB
			local function toggle_context()
				local entry = action_state.get_selected_entry()
				local file_path = entry.path

				if not file_path then
					print("No file selected")
					return
				end

				if M.is_in_context(file_path) then
					M.remove_from_context(file_path)
				else
					table.insert(context.files, file_path)
				end

				-- Refresh Telescope picker display
				local picker = action_state.get_current_picker(prompt_bufnr)
				picker:refresh(picker._finder, { reset_prompt = false })
			end

			-- Apply changes on ENTER and close picker
			local function apply_changes_and_close()
				actions.close(prompt_bufnr)
				print("Context updated")
			end

			-- Close picker without applying changes on ESC
			local function close_without_changes()
				actions.close(prompt_bufnr)
				print("No changes applied")
			end

			map("i", "<Tab>", toggle_context)
			map("n", "<Tab>", toggle_context)

			map("i", "<CR>", apply_changes_and_close)
			map("n", "<CR>", apply_changes_and_close)

			map("i", "<Esc>", close_without_changes)
			map("n", "<Esc>", close_without_changes)

			return true
		end,
		entry_maker = function(entry)
			local make_entry = require("telescope.make_entry")
			local default_entry_maker = make_entry.gen_from_file({})

			local default_entry = default_entry_maker(entry)

			-- Add indicator to display
			local original_display = default_entry.display
			default_entry.display = function(entry_tbl)
				local display, hl_group = original_display(entry_tbl)
				local in_context = M.is_in_context(default_entry.path) -- Dynamically check
				local marker = in_context and "[x] " or "[ ] "
				return marker .. display, hl_group
			end

			return default_entry
		end,
	})
end

function M.is_in_context(file_path)
	for _, existing_file in ipairs(context.files) do
		if existing_file == file_path then
			return true
		end
	end
	return false
end

function M.remove_from_context(file_path)
	for i, existing_file in ipairs(context.files) do
		if existing_file == file_path then
			table.remove(context.files, i)
			return
		end
	end
end

return M
