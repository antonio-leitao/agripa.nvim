-- Create new file: lua/agripa/output_buffer.lua
local M = {}

-- Store the buffer number for reuse
local output_buffer = nil

-- Function to create or get the output buffer
function M.get_output_buffer()
	if output_buffer and vim.api.nvim_buf_is_valid(output_buffer) then
		-- Clear existing content
		vim.api.nvim_buf_set_lines(output_buffer, 0, -1, false, {})
		return output_buffer
	end

	-- Create new buffer
	output_buffer = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(output_buffer, "buftype", "nofile")
	vim.api.nvim_buf_set_option(output_buffer, "bufhidden", "hide")
	vim.api.nvim_buf_set_option(output_buffer, "swapfile", false)
	vim.api.nvim_buf_set_option(output_buffer, "filetype", "markdown")
	vim.api.nvim_buf_set_name(output_buffer, "Agripa Output")

	return output_buffer
end

-- Function to display buffer in vsplit
function M.display_in_vsplit(buf_nr)
	-- Create vertical split
	vim.cmd("vsplit")
	-- Get the window ID of the new split
	local win_id = vim.api.nvim_get_current_win()
	-- Set the buffer in the new window
	vim.api.nvim_win_set_buf(win_id, buf_nr)
end

return M
