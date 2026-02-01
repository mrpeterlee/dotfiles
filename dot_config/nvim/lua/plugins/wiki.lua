-- Wiki.Vim

return {
  {
    -- This is a Vim plugin to manage text based lists and check lists.
    "lervag/lists.vim",
    event = "VeryLazy",
  },
  -- There are a lot of plugins to work with tables. These are both excellent:
  -- { "dhruvasagar/vim-table-mode", },
  -- { "junegunn/vim-easy-align" },
  {
    "lervag/wiki.vim",
    event = "VeryLazy",
    init = function()
      vim.g.wiki_root = "/lab/paper/notes"
      vim.g.wiki_index_name = "todo.md"
    end,
  },
}
