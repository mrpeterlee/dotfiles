return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = function(_, opts)
    opts = opts or {}
    opts.html = vim.tbl_deep_extend("force", opts.html or {}, { enabled = false })
    opts.latex = vim.tbl_deep_extend("force", opts.latex or {}, { enabled = false })
    opts.yaml = vim.tbl_deep_extend("force", opts.yaml or {}, { enabled = false })
    return opts
  end,
}
