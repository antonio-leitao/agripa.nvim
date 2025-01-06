local utils = require("agripa.utils")
local context = require("agripa.context")

local M = {}

-- Placeholder AI function
function M.get_response(context_content, current_file, prompt)
	local response = string.format(
		[[
<context>
%s
</context>

<current_file>
%s
</current_file>]],
		context_content,
		current_file
	)

	-- Only add prompt section if there's a prompt
	if prompt and prompt ~= "" then
		response = response .. string.format(
			[[

<prompt>
%s
</prompt>]],
			prompt
		)
	end

	return response
end

-- Function to process AI request
function M.process_request()
	local context_content = context.get_content()
	local current_file = vim.fn.expand("%:p")
	local prompt = utils.get_visual_selection()

	-- Get cursor position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local row = cursor_pos[1]

	-- Get AI response
	local response = M.get_response(context_content, current_file, prompt)

	-- Insert response at cursor position
	local lines = vim.split(response, "\n")
	vim.api.nvim_buf_set_lines(0, row, row, false, lines)
end

return M
