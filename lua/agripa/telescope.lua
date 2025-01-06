local context = require("agripa.context")

local M = {}

-- Telescope integration for adding files
function M.add_to_context()
	local telescope = require("telescope.builtin")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	telescope.find_files({
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()

				if selection then
					local file_path = selection.path
					-- Check if file is already in context
					for _, existing_file in ipairs(context.files) do
						if existing_file == file_path then
							print("File already in context: " .. file_path)
							return
						end
					end

					table.insert(context.files, file_path)
					print("Added to context: " .. file_path)
				end
			end)
			return true
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
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()

					if selection then
						local file_path = selection[1]
						for i, existing_file in ipairs(context.files) do
							if existing_file == file_path then
								table.remove(context.files, i)
								print("Removed from context: " .. file_path)
								return
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
