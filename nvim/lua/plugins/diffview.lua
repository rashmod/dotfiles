return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles" },
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("diffview").setup({
			enhanced_diff_hl = true,
			hooks = {
				diff_buf_win_enter = function(_, winid, ctx)
					local side_hl = {
						a = {
							"DiffAdd:DiffviewDiffAddAsDelete",
							"DiffDelete:DiffviewDiffDeleteDim",
							"DiffChange:DiffviewDiffChangeDelete",
							"DiffText:DiffviewDiffTextDelete",
						},
						b = {
							"DiffDelete:DiffviewDiffDeleteDim",
							"DiffAdd:DiffviewDiffAdd",
							"DiffChange:DiffviewDiffChangeAdd",
							"DiffText:DiffviewDiffTextAdd",
						},
					}
					local win_hl = side_hl[ctx.symbol]

					if win_hl then
						vim.wo[winid].winhighlight = table.concat(win_hl, ",")
					end
				end,
			},
		})
	end,
}
