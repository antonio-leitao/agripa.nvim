local M = {}

-- Helper function to get plugin root directory
local function get_plugin_root()
	-- Get the directory of the current file (prompts.lua)
	local current_file = debug.getinfo(1, "S").source:sub(2)
	-- Go up one directory to get to the agripa root
	return vim.fn.fnamemodify(current_file, ":h")
end

-- Helper function to load file content from prompts directory
local function load_prompt_file(subdir, filename)
	local plugin_root = get_plugin_root()
	local file_path = plugin_root .. "/prompts/" .. subdir .. "/" .. filename

	local file = io.open(file_path, "r")
	if not file then
		error(string.format("Could not find prompt file: %s\nExpected at: %s", filename, file_path))
	end

	local content = file:read("*a")
	file:close()
	return content
end

-- Function to load system prompt
function M.load_system_prompt(filename)
	return load_prompt_file("system", filename)
end

-- Function to load template
function M.load_template(filename)
	return load_prompt_file("template", filename)
end

-- Function to fill template with provided content
function M.fill_template(template, parts)
	-- Create a copy of the template
	local filled = template

	-- Replace each tag with its content if provided
	for tag, content in pairs(parts) do
		local tag_pattern = "{{" .. tag .. "}}"
		if content and content ~= "" then
			filled = filled:gsub(tag_pattern, content)
		else
			-- If content is empty or nil, remove the entire tag section
			local section_pattern = "\n<" .. tag .. ">\n" .. tag_pattern .. "\n</" .. tag .. ">\n"
			filled = filled:gsub(section_pattern, "")
		end
	end

	return filled
end

-- Main function to format prompt using template
function M.format_prompt(template_name, parts)
	local template = M.load_template(template_name)
	return M.fill_template(template, parts)
end

return M
