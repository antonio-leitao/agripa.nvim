local utils = require("agripa.utils")
local config = require("agripa").config

local M = {}

-- Store our context file paths
M.files = {}

-- Function to get formatted context content
function M.get_content()
	local all_content = {}

	-- First, let's get the current file path
	local current_file = vim.fn.expand("%:p")
	local current_content = utils.get_current_buffer()
	local is_current_in_context = false

	-- Check if current file is in context and build context content
	for _, file_path in ipairs(M.files) do
		local content = utils.read_file(file_path)
		if content then
			if file_path == current_file then
				is_current_in_context = true
				-- Use current buffer content instead of file content for current file
				table.insert(all_content, utils.format_file_content(file_path, current_content))
			else
				table.insert(all_content, utils.format_file_content(file_path, content))
			end
		end
	end

	-- If auto-include is enabled and current file is not in context, add it
	if config.auto_include_current and not is_current_in_context and current_file ~= "" then
		table.insert(all_content, utils.format_file_content(current_file, current_content))
	end

	return table.concat(all_content, "\n\n"), is_current_in_context
end

return M
