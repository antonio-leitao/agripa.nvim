local utils = require("agripa.utils")
local context = require("agripa.context")
local config = require("agripa")
local gemini = require("agripa.ai.gemini")
local prompts = require("agripa.prompts")

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
	-- Prepare the parts for template filling
	local parts = {
		context = context_content,
		current_file = current_file,
		highlighted = highlighted_text,
		prompt = prompt,
	}

	-- Get template name from config
	local template_name = config.config.prompt_template or "default.txt"

	-- Load and fill the template
	return prompts.format_prompt(template_name, parts)
end

function M.process_request_with_prompt(prompt)
	local context_content, _ = context.get_content()
	local current_file = vim.fn.expand("%:p")
	local highlighted_text = utils.get_visual_selection()

	-- Format the complete input for the AI
	local input = M.get_response(context_content, current_file, highlighted_text, prompt)

	-- Variables to store buffer info for later use
	local buf_nr, row

	-- Show "Thinking..." message and prepare for response
	vim.schedule(function()
		if config.config.use_separate_buffer then
			-- Get or create output buffer
			local output_buffer = require("agripa.output_buffer")
			buf_nr = output_buffer.get_output_buffer()

			-- Set the "Thinking..." message
			vim.api.nvim_buf_set_lines(buf_nr, 0, -1, false, { "Thinking..." })

			-- Display the buffer if it's not already visible
			local buf_windows = vim.fn.win_findbuf(buf_nr)
			if #buf_windows == 0 then
				output_buffer.display_in_vsplit(buf_nr)
			end
		else
			-- Get cursor position and insert "Thinking..." in current buffer
			local cursor_pos = vim.api.nvim_win_get_cursor(0)
			row = cursor_pos[1]
			buf_nr = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_lines(buf_nr, row - 1, row - 1, false, { "Thinking..." })
		end

		-- Force a redraw to show the "Thinking..." message
		vim.cmd("redraw")

		-- Get AI response in a new thread
		vim.schedule(function()
			-- Get AI response based on configured model
			local response
			if config.config.model == "gemini" then
				response = gemini.generate_response(input)
			else
				error("Unsupported AI model: " .. config.config.model)
			end

			-- Add error handling for nil response
			if not response then
				error("Received nil response from AI model")
			end

			-- Split response into lines
			local lines = vim.split(response, "\n", { plain = true })

			-- Schedule the UI update with the response
			vim.schedule(function()
				if config.config.use_separate_buffer then
					-- Replace "Thinking..." with the actual response
					vim.api.nvim_buf_set_lines(buf_nr, 0, -1, false, lines)
				else
					-- Replace "Thinking..." with the actual response in current buffer
					vim.api.nvim_buf_set_lines(buf_nr, row - 1, row, false, lines)
				end
			end)
		end)
	end)
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
