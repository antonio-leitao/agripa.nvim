# Agripa

A Neovim plugin for AI-powered code assistance.

## Features

-   **Context Management:** Add files to the AI's context for more informed responses.
-   **AI Prompting:** Send prompts to the AI model and insert the response directly into your code.
-   **Clipboard Integration:** Copy the current context to the clipboard for sharing.
-   **Configurable AI Model:** Supports different AI models (currently Gemini).
-   **Customizable Prompts:** Use templates to format your requests.
-   **Telescope Integration:** Use Telescope to easily add and remove files from the context.
    
## Installation

Using packer:
```lua
use {
  "antonio-leitao/agripa.nvim",
  config = function()
    require("agripa").setup()
  end,
}
```
Using lazy:
```lua
{
  "antonio-leitao/agripa.nvim",
  config = function()
    require("agripa").setup()
  end,
}
```

## Usage

### Commands
-   `:AgripaAdd` - Add files to the context using Telescope.
-   `:AgripaRemove` - Remove files from the context using Telescope.
-   `:AgripaList` - List all files currently in the context.
-   `:AgripaAI` - Open a prompt window and send a request to the AI model.
-   `:AgripaYank` - Copy the current context to the clipboard.

### Configuration
You can customize Agripa by passing a table to the `setup` function.

```lua
require('agripa').setup({
  auto_include_current = true,
  model = "gemini",
  system_prompt = "coder.txt",
  prompt_template = "coder.txt"
})
```

-   `auto_include_current`: Automatically include the current file in the context.
-   `model`: The AI model to use (e.g., "gemini").
-   `system_prompt`: The system prompt file to use.
-   `prompt_template`: The prompt template file to use.

## Dependencies

-   [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
-   [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## API Key
Set the `GOOGLE_API_KEY` environment variable for Gemini models.

