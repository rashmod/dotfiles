return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		-- Keep the line under the cursor rendered in normal mode.
		anti_conceal = { enabled = false },
	},
	keys = {
		{
			"<leader>mt",
			function()
				require("render-markdown").toggle()
			end,
			desc = "[M]arkdown [T]oggle rendering",
		},
		{
			"<leader>mp",
			function()
				require("render-markdown").preview()
			end,
			desc = "[M]arkdown split [P]review",
		},
	},
}
