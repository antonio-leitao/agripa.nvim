local M = {}

-- Default configuration
M.config = {
	auto_include_current = true, -- automatically include current file in context
}

-- Setup function with user config
function M.setup(opts)
	opts = opts or {}
	M.config = vim.tbl_deep_extend("force", M.config, opts)

	-- Create commands
	require("agripa.commands").setup()
end

return M
