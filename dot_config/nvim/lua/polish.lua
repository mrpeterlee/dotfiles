-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
-- vim.filetype.add {
--   extension = {
--     foo = "fooscript",
--   },
--   filename = {
--     ["Foofile"] = "fooscript",
--   },
--   pattern = {
--     ["~/%.config/foo/.*"] = "fooscript",
--   },
-- }

-- Disable unused providers to clean up health warnings
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Align TERM with tmux default to avoid color issues
if vim.env.TMUX and vim.env.TERM ~= "screen-256color" then vim.env.TERM = "screen-256color" end

-- ==================== Mapping Graphite Layout ==================== --
-- k --> ,
-- , --> '
-- a --> k
-- l --> a
-- e --> l
-- j --> <left>e
-- h --> j
-- y --> h
-- ' --> y

-- %s/: Y/: '/gc
-- %s/: H/: Y/gc
-- %s/: J/: H/gc
-- %s/: E/: J/gc
-- %s/: L/: E/gc
-- %s/: A/: L/gc
-- %s/: K/: A/gc
--
-- %s/: y/: '/gc
-- %s/: j/: h/gc
-- %s/: e/: j/gc
-- %s/: l/: e/gc
-- %s/: a/: l/gc
-- %s/: k/: a/gc
-- %s/: h/: y/gc

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend("force", options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Normal Mode Graphite
-- map("n", "y", "h") -- move Left
-- map("n", "h", "gj") -- move Down (g to allow move within wrapped lines)
-- map("n", "a", "gk") -- move Up (g to allow move within wrapped lines)
-- map("n", "e", "l") -- move Right
map("n", "y", "<left>") -- move Left
map("n", "h", "gj") -- move Down (g to allow move within wrapped lines)
map("n", "a", "gk") -- move Up (g to allow move within wrapped lines)
map("n", "e", "<right>") -- move Right
map("n", "j", "e") -- end of word      replaces (e)nd
map("n", "l", "a") -- l to append word
map("n", "L", "A") -- l to append word
map("n", "'", "y") -- , to copy
map("n", ",", "'") -- , to copy

-- Visual Mode Graphite
-- map("v", "y", "h") -- move Left
-- map("v", "h", "j") -- move Down (g to allow move within wrapped lines)
-- map("v", "a", "k") -- move Up (g to allow move within wrapped lines)
-- map("v", "e", "l") -- move Right
map("v", "y", "<left>") -- move Left
map("v", "h", "<down>") -- move Down (g to allow move within wrapped lines)
map("v", "a", "<up>") -- move Up (g to allow move within wrapped lines)
map("v", "e", "<right>") -- move Right
map("v", "j", "e") -- end of word      replaces (e)nd
map("v", "l", "a") -- l to append word
map("v", "L", "A") -- l to append word

-- Keep cursor where yank was triggered (works for forward/backward selections)
map("v", "'", "mjy`j", { silent = true })
map("v", ",", "mjy`j", { silent = true })

-- Enter commands without pressing shift
-- map("n", ";", ":")
-- map("n", ":", ";")

-- Jump, then center
map("n", "}", "}zz")
map("n", "{", "{zz")
map("n", "<PageDown>", "<C-d>zz", { noremap = true })
map("n", "<C-d>", "<C-d>zz", { noremap = true })
-- map("n", "<C-b>", "<C-b>zz", { noremap = true })
map("n", "<PageUp>", "<C-u>zz", { noremap = true })
map("n", "<C-u>", "<C-u>zz", { noremap = true })
-- map("n", "<C-f>", "<C-f>zz", { noremap = true })

-- Yank line to ''
vim.keymap.set("n", "''", "<Cmd>normal! yy<CR>", { noremap = true, silent = true })

-- Remap <A-v> to <C-v> for visual block mode
vim.api.nvim_set_keymap("n", "<A-v>", "<C-v>", { noremap = true, silent = true })

-- Other keymaps
-- Swap Ctrl+h and Ctrl+f
-- Swap Ctrl+a and Ctrl+b
-- map("n", "<C-h>", "<C-f>zz", { noremap = true })
-- map("n", "<C-a>", "<C-b>zz", { noremap = true })
-- map("i", "<C-h>", "<C-f>zz", { noremap = true })
-- map("i", "<C-a>", "<C-b>zz", { noremap = true })
