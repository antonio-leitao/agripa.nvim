local curl = require("plenary.curl")
local config = require("agripa").config
local prompts = require("agripa.prompts")

local M = {}

-- Function to get API key
function M.get_api_key()
	local api_key = os.getenv("GOOGLE_API_KEY")
	if not api_key then
		error("GOOGLE_API_KEY environment variable not set")
	end
	return api_key
end

function M.generate_response(input_text)
	local api_key = M.get_api_key()
	local system_prompt = prompts.load_system_prompt(config.system_prompt)

	local response = curl.post(
		"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=" .. api_key,
		{
			timeout = 30000,
			headers = {
				["Content-Type"] = "application/json",
			},
			body = vim.fn.json_encode({
				contents = {
					{
						role = "user",
						parts = {
							{
								text = input_text,
							},
						},
					},
				},
				systemInstruction = {
					role = "user",
					parts = {
						{
							text = system_prompt,
						},
					},
				},
				generationConfig = {
					temperature = 1,
					topK = 40,
					topP = 0.95,
					maxOutputTokens = 8192,
					responseMimeType = "text/plain",
				},
			}),
		}
	)

	if response.status ~= 200 then
		error("API request failed with status " .. response.status .. ": " .. response.body)
	end

	local result = vim.fn.json_decode(response.body)
	print("Decoded response: " .. vim.inspect(result))

	if
		result
		and result.candidates
		and result.candidates[1]
		and result.candidates[1].content
		and result.candidates[1].content.parts
		and result.candidates[1].content.parts[1]
		and result.candidates[1].content.parts[1].text
	then
		return result.candidates[1].content.parts[1].text
	else
		error("Invalid response format from Gemini API")
	end
end

return M
