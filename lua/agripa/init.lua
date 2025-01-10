local M = {}

-- Extended default configuration
M.config = {
	auto_include_current = true,
	model = "gemini",
	system_prompt = "coder.txt",
	prompt_template = "coder.txt",
	use_separate_buffer = true, -- Add this line
}

-- Setup function with user config
function M.setup(opts)
	opts = opts or {}
	M.config = vim.tbl_deep_extend("force", M.config, opts)

	-- Create commands
	require("agripa.commands").setup()
end

return M
