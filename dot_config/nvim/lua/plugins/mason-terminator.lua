---@type LazySpec
return {
  "williamboman/mason.nvim",
  enabled = function() return #vim.api.nvim_list_uis() > 0 end,
  init = function()
    -- In restricted/headless environments (e.g. AppImage extract runs) the
    -- VimLeavePre terminator tries to kill installer processes and can fail
    -- with EPERM. Provide a stub terminator module before Mason loads so the
    -- exit hook is a no-op for headless runs only.
    if #vim.api.nvim_list_uis() > 0 and vim.env.APPIMAGE_EXTRACT_AND_RUN ~= "1" then return end

    package.preload["mason-core.terminator"] = function()
      return {
        terminate = function() end,
        register = function() end,
      }
    end
  end,
}
