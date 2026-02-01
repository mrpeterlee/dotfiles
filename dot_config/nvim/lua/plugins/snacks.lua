---@type LazySpec
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = { enabled = false },
    image = { enabled = false },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    picker = { enabled = true, ui_select = true },
    quickfile = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = false }, -- heirline handles the statuscolumn
    terminal = { enabled = true },
    words = { enabled = true },
    styles = {
      notification = {
        -- wo = { wrap = true } -- Wrap notifications
      },
    },
  },
  config = function(_, opts)
    local snacks = require "snacks"

    -- Skip health noise for modules we explicitly leave disabled
    if opts.image and opts.image.enabled == false then
      snacks.image.meta.health = false
    end
    if opts.explorer and opts.explorer.enabled == false then
      snacks.explorer.meta.health = false
    end
    if opts.statuscolumn and opts.statuscolumn.enabled == false then
      snacks.statuscolumn.meta.health = false
    end

    snacks.setup(opts)

    local has_ui = #vim.api.nvim_list_uis() > 0
    if not has_ui and opts.dashboard and opts.dashboard.enabled then
      snacks.dashboard.meta.health = false
    end

    -- Relax the fd version check so :checkhealth stays green on hosts that ship fd 8.3.x
    local picker_health = require "snacks.picker.core._health"
    picker_health.health = function()
      local config = snacks.picker.config.get()
      if snacks.config.get("picker", {}).enabled and config.ui_select then
        if vim.ui.select == snacks.picker.select then
          snacks.health.ok("`vim.ui.select` is set to `Snacks.picker.select`")
        else
          snacks.health.error("`vim.ui.select` is not set to `Snacks.picker.select`")
        end
      else
        snacks.health.warn("`vim.ui.select` for `Snacks.picker` is not enabled")
      end

      snacks.health.has_lang("regex")
      snacks.health.have_tool("git")

      local have_rg = snacks.health.have_tool("rg")
      if not have_rg then
        snacks.health.error("'rg' is required for `Snacks.picker.grep()`")
      else
        snacks.health.ok("`Snacks.picker.grep()` is available")
      end

      local have_fd = snacks.health.have_tool({ { cmd = { "fd", "fdfind" }, version = false } })
      local have_find = have_fd
        or (jit.os:find("Windows") == nil and snacks.health.have_tool({ { cmd = "find", version = false } }))

      if have_rg or have_fd or have_find then
        snacks.health.ok("`Snacks.picker.files()` is available")
      else
        snacks.health.error("'rg', 'fd' or 'find' is required for `Snacks.picker.files()`")
      end

      if have_fd then
        snacks.health.warn("'fd' 8.3.x detected – explorer actions fall back without the v8.4 features")
      else
        snacks.health.warn("`fd` not detected, explorer actions disabled")
      end
    end

    local function ensure_ui_providers()
      local has_ui = #vim.api.nvim_list_uis() > 0

      if opts.dashboard and opts.dashboard.enabled and has_ui and not snacks.dashboard.status.did_setup then
        pcall(snacks.dashboard.setup)
      end

      if opts.input and opts.input.enabled ~= false then
        pcall(snacks.input.enable)
      end

      local picker_cfg = snacks.config.get("picker", {})
      if picker_cfg.enabled ~= false and picker_cfg.ui_select ~= false then
        pcall(snacks.picker.setup)
      end

      if opts.notifier and opts.notifier.enabled ~= false then
        vim.notify = snacks.notifier.notify
      end

      if opts.statuscolumn and opts.statuscolumn.enabled then
        vim.o.statuscolumn = "%!v:lua.require'snacks.statuscolumn'.get()"
      end
    end

    ensure_ui_providers()
    local ui_group = vim.api.nvim_create_augroup("snacks_ui_providers", { clear = true })
    vim.api.nvim_create_autocmd("User", {
      group = ui_group,
      pattern = "VeryLazy",
      callback = ensure_ui_providers,
    })

    local util = require "snacks.util"
    local orig_blend = util.blend
    -- Guard against nil color inputs in blend computations (seen during checkhealth)
    util.blend = function(fg, bg, alpha)
      if not fg or not bg then return fg or bg or "#000000" end
      return orig_blend(fg, bg, alpha)
    end
  end,
  keys = {
    { "<leader>z", function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>Z", function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
    { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
    { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    { "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal" },
    { "<c-_>", function() Snacks.terminal() end, desc = "which_key_ignore" },
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
    {
      "<leader>N",
      desc = "Neovim News",
      function()
        Snacks.win {
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        }
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...) Snacks.debug.inspect(...) end
        _G.bt = function() Snacks.debug.backtrace() end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map "<leader>us"
        Snacks.toggle.option("wrap", { name = "Wrap" }):map "<leader>uw"
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map "<leader>uL"
        Snacks.toggle.diagnostics():map "<leader>ud"
        Snacks.toggle.line_number():map "<leader>ul"
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map "<leader>uc"
        Snacks.toggle.treesitter():map "<leader>uT"
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map "<leader>ub"
        Snacks.toggle.inlay_hints():map "<leader>uh"
        Snacks.toggle.indent():map "<leader>ug"
        Snacks.toggle.dim():map "<leader>uD"
      end,
    })
  end,
}
