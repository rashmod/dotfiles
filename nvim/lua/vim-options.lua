-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- vim.g.netrw_liststyle = 3

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.schedule(function()
-- vim.opt.clipboard = "unnamedplus"
-- end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.opt.tabstop = 4 -- Number of spaces a <Tab> character occupies
vim.opt.shiftwidth = 4 -- Number of spaces used for each indentation level
vim.opt.expandtab = true -- Convert tabs to spaces

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- spell checking
vim.opt.spelllang = "en_us"
vim.opt.spell = true

-- line wrapping
vim.opt.wrap = true
vim.opt.linebreak = true

-- vim.o.fileformats = "dos,unix"
-- vim.o.fileformats = "dos"

-- vim.api.nvim_create_autocmd("BufWritePre", {
-- 	pattern = "*",
-- 	command = "set fileformat=dos",
-- })
--
-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("i", "jk", "<Esc>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("n", "<leader>i", "<cmd>w<CR>", { desc = "Save current buffer" })
vim.keymap.set("n", "<leader>g", "<cmd>bd<CR>", { desc = "Close current buffer" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<leader>h", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<leader>l", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<leader>j", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<leader>k", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Move down a logical line" })
vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Move up a logical line" })

vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Move up a logical line" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Move up a logical line" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Keep search term in middle of screen" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Keep search term in middle of screen" })

-- move text in visual modke
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected text down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected text up" })

-- keep cursor in place when appending lines
vim.keymap.set("n", "J", "mzJ`z", { desc = "Keep cursor in place when appending lines" })

vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<CR>", { desc = "Restart Lsp" })

vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape insert mode" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Preserve the yank buffer when pasting" })

vim.keymap.set({ "n", "x" }, "<leader>d", [["_d]], { desc = "Delete without overwriting paste buffer" })

vim.keymap.set({ "n", "x" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

vim.keymap.set({ "n", "x" }, "<leader>P", [["+p]], { desc = "Paste from system clipboard" })

vim.keymap.set("n", "<C-K>", "<cmd>cnext<CR>zz", { desc = "Next in quick fix list" })
vim.keymap.set("n", "<C-J>", "<cmd>cprev<CR>zz", { desc = "Previous in quick fix list" })
vim.keymap.set("n", "<leader>K", "<cmd>lnext<CR>zz", { desc = "TODO: write a desc (quick fix command)" })
vim.keymap.set("n", "<leader>J", "<cmd>lprev<CR>zz", { desc = "TODO: write a desc (quick fix command)" })

vim.keymap.set(
	"n",
	"<leader>rr",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace word under cursor in current buffer" }
)

-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
-- 	pattern = "*.html",
-- 	callback = function()
-- 		if vim.fn.glob("manage.py") ~= "" or vim.fn.glob("app.py") ~= "" then
-- 			vim.bo.filetype = "djhtml"
-- 		end
-- 	end,
-- })
--
-- leetcode
vim.keymap.set("n", "<leader>or", "<cmd>Leet run<CR>", { desc = "Leet run" })
vim.keymap.set("n", "<leader>os", "<cmd>Leet submit<CR>", { desc = "Leet submit" })

-- CUSTOM MACROS
vim.api.nvim_create_augroup("JSLogMacro", { clear = true })
vim.api.nvim_create_autocmd("filetype", {
	group = "JSLogMacro",
	pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	callback = function()
		vim.fn.setreg("l", "oconsole.log('jkpa:', jkpa)jk")
	end,
})
