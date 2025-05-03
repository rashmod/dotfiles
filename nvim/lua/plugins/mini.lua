return { -- Collection of various small independent plugins/modules
	"echasnovski/mini.nvim",
	config = function()
		-- Better Around/Inside textobjects
		--
		-- Examples:
		--  - va)  - [V]isually select [A]round [)]paren
		--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
		--  - ci'  - [C]hange [I]nside [']quote
		require("mini.ai").setup({ n_lines = 500 })

		-- Add/delete/replace surroundings (brackets, quotes, etc.)
		--
		-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
		-- - sd'   - [S]urround [D]elete [']quotes
		-- - sr)'  - [S]urround [R]eplace [)] [']
		require("mini.surround").setup()

		-- Simple and easy statusline.
		--  You could remove this setup call if you don't like it,
		--  and try some other statusline plugin
		local statusline = require("mini.statusline")

		-- Your config table
		local my_config = {
			-- set use_icons to true if you have a Nerd Font
			use_icons = vim.g.have_nerd_font,
			set_vim_settings = true,
		}

		-- Setup with your config
		statusline.setup(my_config)

		-- Show only the file name (no path)
		---@diagnostic disable-next-line: duplicate-set-field
		statusline.section_filename = function()
			local name = vim.fn.expand("%:t")
			local modified = vim.bo.modified and " [+]" or ""
			return name .. modified
		end

		-- You can configure sections in the statusline by overriding their
		-- default behavior. For example, here we set the section for
		-- cursor location to LINE:COLUMN
		---@diagnostic disable-next-line: duplicate-set-field
		statusline.section_location = function()
			return "%2l:%-2v"
		end

		vim.api.nvim_set_hl(0, "MyStatusFilename", {
			fg = "#C1C7E0", -- or whatever your theme uses for normal text
			bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg, -- match editor bg
		})

		-- Style the statusline for inactive windows
		---@diagnostic disable-next-line: duplicate-set-field
		statusline.inactive = function()
			vim.api.nvim_win_set_option(0, "winhighlight", "StatusLine:StatusLineNC")

			return table.concat({
				"", -- No mode
				statusline.section_git(my_config),
				statusline.section_diagnostics(my_config),
				"%#MyStatusFilename#",
				statusline.section_filename(my_config),
				"%=",
				"%#StatusLineNC#",
				statusline.section_searchcount(my_config),
				statusline.section_location(my_config),
			}, " ")
		end

		vim.cmd([[highlight StatusLineNC guibg=#2F313D guifg=#A3AAC2]])

		-- ... and there is more!
		--  Check out: https://github.com/echasnovski/mini.nvim
		--
		local hipatterns = require("mini.hipatterns")
		hipatterns.setup({
			highlighters = {
				-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
				fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
				hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
				todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
				note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

				-- Highlight hex color strings (`#rrggbb`) using that color
				hex_color = hipatterns.gen_highlighter.hex_color(),
			},
		})
	end,
}
