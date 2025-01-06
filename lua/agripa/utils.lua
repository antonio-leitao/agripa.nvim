local M = {}

-- Function to read file contents
function M.read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

-- Function to format a single file content
function M.format_file_content(file_path, content)
	local separator = string.rep("=", #file_path)
	return string.format("%s\n%s\n%s", file_path, separator, content)
end

-- Function to get current buffer content
function M.get_current_buffer()
	return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end

-- Function to get visual selection
function M.get_visual_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)

	if #lines == 0 then
		return ""
	end

	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
	else
		lines[1] = string.sub(lines[1], start_pos[3])
		lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
	end

	return table.concat(lines, "\n")
end

return M
