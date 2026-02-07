-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- import/override with your plugins folder
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.python-ruff" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.ps1" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.yaml" },

  -- Trouble - Display diagnostics, references, telescope results, quickfix list and location list in a floating window.
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.quickfix.nvim-bqf" },

  -- TMUX
  { import = "astrocommunity.terminal-integration.vim-tmux-yank" },
  { import = "astrocommunity.terminal-integration.vim-tmux-navigator" },

  -- Themes
  { import = "astrocommunity.colorscheme.monokai-pro-nvim" },
  { import = "astrocommunity.colorscheme.onedarkpro-nvim" },
  { import = "astrocommunity.colorscheme.sonokai" },

  { import = "astrocommunity.recipes.heirline-nvchad-statusline" },

  -- AI
  { import = "astrocommunity.editing-support.copilotchat-nvim" },
  { import = "astrocommunity.editing-support.chatgpt-nvim" },

  -- Markdown
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },

  -- VsCode Neovim Plugin
  { import = "astrocommunity.recipes.vscode" },
  { import = "astrocommunity.recipes.vscode-icons" },

  -- Neovide
  { import = "astrocommunity.recipes.neovide" },

  -- Bad Practices
  -- { import = "astrocommunity.workflow.bad-practices-nvim" },
  -- { import = "astrocommunity.workflow.hardtime-nvim" },
  -- { import = "astrocommunity.workflow.precognition-nvim" },

  -- Terminal
  { import = "astrocommunity.terminal-integration.nvim-unception" },
}
