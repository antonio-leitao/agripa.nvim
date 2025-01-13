local telescope = require("agripa.telescope")
local context = require("agripa.context")
local M = {}

function M.setup()
	vim.api.nvim_create_user_command("AgripaContext", telescope.toggle_context, {})
	vim.api.nvim_create_user_command("AgripaList", function()
		if #context.files == 0 then
			print("No files in context")
			return
		end
		print("Files in context:")
		for _, file in ipairs(context.files) do
			print(file)
		end
	end, {})
	vim.api.nvim_create_user_command("AgripaAI", require("agripa.ai").process_request, {})
	vim.api.nvim_create_user_command("AgripaYank", require("agripa.ai").copy_context_to_clipboard, {})
end

return M
