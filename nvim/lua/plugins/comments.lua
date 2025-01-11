return {
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	-- {
	-- 	"JoosepAlviste/nvim-ts-context-commentstring",
	-- 	-- setup = {
	-- 	-- 	enable_autocmd = false,
	-- 	-- },
	-- },
	-- { "folke/ts-comments.nvim", opts = {}, event = "VeryLazy" },
	{
		"numToStr/Comment.nvim",
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},

		config = function()
			local pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
			require("Comment").setup({
				padding = true,
				sticky = true,
				ignore = "^$",
				toggler = {
					---Line-comment toggle keymap
					line = "gcc",
					---Block-comment toggle keymap
					block = "gbc",
				},
				opleader = {
					---Line-comment keymap
					line = "gc",
					---Block-comment keymap
					block = "gb",
				},
				---LHS of extra mappings
				extra = {
					---Add comment on the line above
					above = "gcO",
					---Add comment on the line below
					below = "gco",
					---Add comment at the end of line
					eol = "gcA",
				},

				---Enable keybindings
				---NOTE: If given `false` then the plugin won't create any mappings
				mappings = {
					---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
					basic = true,
					---Extra mapping; `gco`, `gcO`, `gcA`
					extra = true,
				},

				---Function to call before (un)comment
				pre_hook = pre_hook,
				---Function to call after (un)comment
				post_hook = function() end,
			})
		end,
	},
}
