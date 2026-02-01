---@type LazySpec
return {
  "christoomey/vim-tmux-navigator",
  init = function()
    -- Silence netrw mapping warning from vim-tmux-navigator
    vim.g.tmux_navigator_disable_netrw_workaround = 1
  end,
}
