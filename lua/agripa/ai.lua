local utils = require("agripa.utils")
local context = require("agripa.context")

local M = {}

-- Function to create the floating window
function M.create_prompt_window()
	local width = 60
	local height = 10
	local buf = vim.api.nvim_create_buf(false, true)

	-- Get editor dimensions
	local ui = vim.api.nvim_list_uis()[1]
	local win_width = ui.width
	local win_height = ui.height

	-- Calculate centered position
	local row = math.floor((win_height - height) / 2)
	local col = math.floor((win_width - width) / 2)

	-- Set window options
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		anchor = "NW",
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)

	-- Set buffer options
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

	-- Add a keymap to submit the prompt
	vim.keymap.set("n", "<CR>", function()
		local prompt_text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
		vim.api.nvim_win_close(win, true)
		M.process_request_with_prompt(prompt_text)
	end, { buffer = buf })

	-- Add a keymap to cancel
	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf })

	-- Set window options
	vim.api.nvim_win_set_option(win, "wrap", true)
	vim.api.nvim_win_set_option(win, "cursorline", true)

	-- Enter insert mode
	vim.cmd("startinsert")
end

-- Function to get formatted prompt content
function M.get_response(context_content, current_file, highlighted_text, prompt)
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

	-- Add highlighted text section if present
	if highlighted_text and highlighted_text ~= "" then
		response = response .. string.format(
			[[

<highlighted>
%s
</highlighted>]],
			highlighted_text
		)
	end

	-- Add prompt section if present
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

-- Function to process AI request with optional prompt
function M.process_request_with_prompt(prompt)
	local context_content, _ = context.get_content()
	local current_file = vim.fn.expand("%:p")
	local highlighted_text = utils.get_visual_selection()

	-- Get cursor position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local row = cursor_pos[1]

	-- Get AI response
	local response = M.get_response(context_content, current_file, highlighted_text, prompt)

	-- Insert response at cursor position
	local lines = vim.split(response, "\n")
	vim.api.nvim_buf_set_lines(0, row, row, false, lines)
end

-- Function to copy context to clipboard
function M.copy_context_to_clipboard()
	local context_content, _ = context.get_content()
	vim.fn.setreg(
		"+",
		string.format(
			[[
<context>
%s
</context>]],
			context_content
		)
	)
	print("Context copied to clipboard")
end

-- Original process_request now opens the prompt window
function M.process_request()
	M.create_prompt_window()
end

return M
