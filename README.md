# Agripa

A Neovim plugin for AI-powered code assistance.

<p align="center">
  <img alt="Agripa Demo" src="assets/demo.gif" width="600" />
</p>

## Features

### Persistent Context Management
- **Keep Relevant Files in Context:** Agripa allows you to add multiple files to a persistent context, ensuring that the AI has all the necessary information for each request.
- **User-Managed Context:** You have full control over the context. Add or remove files as needed.
- **Intelligent Context Usage:** The plugin automatically includes the content of your context files when you interact with the AI, making sure it understands the project's structure and logic.

### Seamless AI Integration
- **Prompt Window:** Easily craft prompts through a floating window, which supports multi-line inputs.
- **Multiple AI Model Support:** Choose between models like Gemini for flexible AI interaction.
- **Thinking Feedback:** See immediate "Thinking..." feedback in your buffer, keeping you informed during processing.
- **Response Display:** AI-generated responses are displayed either in a separate buffer or directly in your current buffer.

### Enhanced Workflow
- **Telescope Integration:** Use Telescope to easily add or remove files from the context.
- **Clipboard Context:** Copy the current context to your clipboard with a single command.
- **Automatic Inclusion:** Configure the plugin to automatically include the current file in the context if not already added.

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
-   `:AgripaContext` - Add and remove files to the context using Telescope.
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
  prompt_template = "coder.txt",
  use_separate_buffer = true
})
```

-   `auto_include_current`: Automatically include the current file in the context.
-   `model`: The AI model to use (e.g., "gemini").
-   `system_prompt`: The system prompt file to use.
-   `prompt_template`: The prompt template file to use.
-   `use_separate_buffer`: Output the AI response in a separate buffer

## Dependencies

-   [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
-   [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## API Key
Set the `GOOGLE_API_KEY` environment variable for Gemini models.
