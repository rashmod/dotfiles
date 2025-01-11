return {
	"kevinhwang91/nvim-ufo",
	dependencies = "kevinhwang91/promise-async",
	opts = {
		provider_selector = function(bufnr, filetype, buftype)
			return { "lsp", "indent" }
			-- return { "tresitter", "indent" }
		end,
	},
	config = function()
		require("ufo").setup()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
		vim.opt.foldcolumn = "1"
		vim.opt.foldenable = true

		vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
		vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
		vim.keymap.set("n", "zK", require("ufo").peekFoldedLinesUnderCursor, { desc = "Peek folds under cursor" })
	end,
}
