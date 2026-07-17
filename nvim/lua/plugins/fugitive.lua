return {
	"tpope/vim-fugitive",
	cmd = { "Git", "G", "Gvdiffsplit", "Gdiffsplit" },
	keys = {
		{ "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
		{ "<leader>gd", "<cmd>Gvdiffsplit<cr>", desc = "Git diff split" },
	},
}
