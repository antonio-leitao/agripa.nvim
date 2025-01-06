local telescope = require("agripa.telescope")
local ai = require("agripa.ai")
local context = require("agripa.context")

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("AgripaAdd", telescope.add_to_context, {})
	vim.api.nvim_create_user_command("AgripaRemove", telescope.remove_from_context, {})
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
	vim.api.nvim_create_user_command("AgripaAI", ai.process_request, {})
	vim.api.nvim_create_user_command("AgripaYank", ai.copy_context_to_clipboard, {})
end

return M
