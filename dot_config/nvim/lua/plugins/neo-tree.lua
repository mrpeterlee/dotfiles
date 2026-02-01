return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        position = "left", -- left, right, top, bottom, float, current
        width = 40, -- applies to left and right positions
        height = 15, -- applies to top and bottom positions
        auto_expand_width = true, -- expand the window when file exceeds the window width. does not work with position = "float"

        mappings = {
          -- Graphite layout
          ["a"] = "prev_sibling", -- up
          ["y"] = "navigate_up", -- up a level (built-in)
          ["h"] = "next_sibling", -- down
          ["e"] = "open", -- into folder/file
          ["<space>"] = {
            "toggle_node",
            nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
          },
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          -- ["<cr>"] = { "open", config = { expand_nested_files = true } }, -- expand nested file takes precedence
          ["<esc>"] = "cancel", -- close preview or floating neo-tree window
          ["P"] = {
            "toggle_preview",
            config = {
              use_float = true,
              use_image_nvim = false,
              -- title = "Neo-tree Preview", -- You can define a custom title for the preview floating window.
            },
          },
          ["<C-f>"] = { "scroll_preview", config = { direction = -10 } },
          ["<C-b>"] = { "scroll_preview", config = { direction = 10 } },
          -- ["l"] = "focus_preview",
          ["S"] = "open_split",
          -- ["S"] = "split_with_window_picker",
          ["s"] = "open_vsplit",
          -- ["sr"] = "open_rightbelow_vs",
          -- ["sl"] = "open_leftabove_vs",
          -- ["s"] = "vsplit_with_window_picker",
          ["t"] = "open_tabnew",
          -- ["<cr>"] = "open_drop",
          -- ["t"] = "open_tab_drop",
          ["w"] = "open_with_window_picker",
          ["C"] = "close_node",
          ["z"] = "close_all_nodes",
          --["Z"] = "expand_all_nodes",
          ["R"] = "refresh",
          ["l"] = {
            "add",
            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
            config = {
              show_path = "none", -- "none", "relative", "absolute"
            },
          },
          ["L"] = "add_directory", -- also accepts the config.show_path and config.insert_as options.
          ["d"] = "delete",
          ["r"] = "rename",
          ["b"] = "rename_basename",
          ["'"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy", -- takes text input for destination, also accepts the config.show_path and config.insert_as options
          ["m"] = "move", -- takes text input for destination, also accepts the config.show_path and config.insert_as options
          ["-"] = "toggle_auto_expand_width",
          ["q"] = "close_window",
          ["?"] = "show_help",
          ["<"] = "prev_source",
          [">"] = "next_source",
        },
      },
      filesystem = {
        window = {
          mappings = {
            ["H"] = "toggle_hidden",
            ["/"] = "fuzzy_finder",
            ["D"] = "fuzzy_finder_directory",
            --["/"] = "filter_as_you_type", -- this was the default until v1.28
            ["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
            -- ["D"] = "fuzzy_sorter_directory",
            ["f"] = "filter_on_submit",
            ["<C-x>"] = "clear_filter",
            ["<bs>"] = "navigate_up",
            ["."] = "set_root",
            ["[g"] = "prev_git_modified",
            ["]g"] = "next_git_modified",
            ["i"] = "show_file_details", -- see `:h neo-tree-file-actions` for options to customize the window.
            ["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
            ["oc"] = { "order_by_created", nowait = false },
            ["od"] = { "order_by_diagnostics", nowait = false },
            ["og"] = { "order_by_git_status", nowait = false },
            ["om"] = { "order_by_modified", nowait = false },
            ["on"] = { "order_by_name", nowait = false },
            ["os"] = { "order_by_size", nowait = false },
            ["ot"] = { "order_by_type", nowait = false },
          },
          fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
            ["<down>"] = "move_cursor_down",
            ["<C-n>"] = "move_cursor_down",
            ["<up>"] = "move_cursor_up",
            ["<C-p>"] = "move_cursor_up",
            ["<esc>"] = "close",
          },
        },
        filtered_items = {
          visible = false, -- when true, they will just be displayed differently than normal items
          force_visible_in_empty_folder = false, -- when true, hidden files will be shown if the root folder is otherwise empty
          show_hidden_count = true, -- when true, the number of hidden items in each folder will be shown as the last entry
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false, -- only works on Windows for hidden files/directories
          hide_by_name = {
            ".DS_Store",
            "thumbs.db",
            --"node_modules",
          },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            --"*/src/*/tsconfig.json"
          },
          always_show = { -- remains visible even if other settings would normally hide it
            --".gitignored",
          },
          always_show_by_pattern = { -- uses glob style patterns
            --".env*",
          },
          never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
            --".DS_Store",
            --"thumbs.db"
          },
          never_show_by_pattern = { -- uses glob style patterns
            --".null-ls_*",
          },
        },
        hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
        -- in whatever position is specified in window.position
        -- "open_current",-- netrw disabled, opening a directory opens within the
        -- window like netrw would, regardless of window.position
        -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
      },
      git_status = {
        window = {
          mappings = {
            ["L"] = "git_add_all",
            ["gu"] = "git_unstage_file",
            ["ga"] = "git_add_file",
            ["gr"] = "git_revert_file",
            ["gc"] = "git_commit",
            ["gp"] = "git_push",
            ["gg"] = "git_commit_and_push",
            ["i"] = "show_file_details", -- see `:h neo-tree-file-actions` for options to customize the window.
            ["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
            ["oc"] = { "order_by_created", nowait = false },
            ["od"] = { "order_by_diagnostics", nowait = false },
            ["om"] = { "order_by_modified", nowait = false },
            ["on"] = { "order_by_name", nowait = false },
            ["os"] = { "order_by_size", nowait = false },
            ["ot"] = { "order_by_type", nowait = false },
          },
        },
      },
    },
  },
}
