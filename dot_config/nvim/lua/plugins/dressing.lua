return {
  "stevearc/dressing.nvim",
  opts = function(_, opts)
    opts = opts or {}
    opts.input = vim.tbl_extend("force", { enabled = false }, opts.input or {})
    opts.select = vim.tbl_extend("force", { enabled = false }, opts.select or {})
    return opts
  end,
}
