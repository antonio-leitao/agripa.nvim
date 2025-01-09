local context = require("agripa.context")
local M = {}

-- Helper function to check if a file is in context
local function is_file_in_context(file_path)
	for _, existing_file in ipairs(context.files) do
		if existing_file == file_path then
			return true
		end
	end
	return false
end

-- Telescope integration for adding files
function M.add_to_context()
	local telescope = require("telescope.builtin")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	telescope.find_files({
		attach_mappings = function(prompt_bufnr, map)
			-- Add custom toggle mapping for multi-select
			map("i", "<tab>", actions.toggle_selection)
			map("n", "<tab>", actions.toggle_selection)

			actions.select_default:replace(function()
				local picker = action_state.get_current_picker(prompt_bufnr)
				local selections = picker:get_multi_selection()

				-- If no multi-selection, get the current selection
				if #selections == 0 then
					local entry = action_state.get_selected_entry()
					if entry then
						selections = { entry }
					end
				end

				actions.close(prompt_bufnr)

				-- Process all selections
				if selections then
					for _, selection in ipairs(selections) do
						local file_path = selection.path
						if not is_file_in_context(file_path) then
							table.insert(context.files, file_path)
							print("Added to context: " .. file_path)
						else
							print("Already in context: " .. file_path)
						end
					end
				end
			end)
			return true
		end,
		entry_maker = function(entry)
			-- Get the default entry maker from telescope
			local make_entry = require("telescope.make_entry")
			local default_entry_maker = make_entry.gen_from_file({})

			-- Create the default entry with icons
			local default_entry = default_entry_maker(entry)
			local in_context = is_file_in_context(entry)

			-- Modify the display function to add context marker
			local original_display = default_entry.display
			default_entry.display = function(entry_tbl)
				local display, hl_group = original_display(entry_tbl)
				if in_context then
					-- Add highlight group for dimmed text
					return "> " .. display, { { { 0, 2 }, "Comment" }, { { 2, #display + 2 }, "Comment" } }
				end
				return display, hl_group
			end

			return default_entry
		end,
	})
end

-- Telescope integration for removing files
function M.remove_from_context()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	-- Only proceed if we have files in context
	if #context.files == 0 then
		print("No files in context to remove")
		return
	end

	pickers
		.new({}, {
			prompt_title = "Remove from Context",
			finder = finders.new_table({
				results = context.files,
				entry_maker = function(entry)
					-- Get the default entry maker from telescope
					local make_entry = require("telescope.make_entry")
					local default_entry_maker = make_entry.gen_from_file({})
					return default_entry_maker(entry)
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				-- Add custom toggle mapping for multi-select
				map("i", "<tab>", actions.toggle_selection)
				map("n", "<tab>", actions.toggle_selection)

				actions.select_default:replace(function()
					local picker = action_state.get_current_picker(prompt_bufnr)
					local selections = picker:get_multi_selection()

					-- If no multi-selection, get the current selection
					if #selections == 0 then
						local entry = action_state.get_selected_entry()
						if entry then
							selections = { entry }
						end
					end

					actions.close(prompt_bufnr)

					-- Process all selections
					if selections then
						for _, selection in ipairs(selections) do
							local file_path = selection.value
							for i, existing_file in ipairs(context.files) do
								if existing_file == file_path then
									table.remove(context.files, i)
									print("Removed from context: " .. file_path)
									break
								end
							end
						end
					end
				end)
				return true
			end,
		})
		:find()
end

return M
