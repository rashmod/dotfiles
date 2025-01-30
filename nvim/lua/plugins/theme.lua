return {
	--[[ { -- You can easily change to a different colorscheme.
		-- Change the name of the colorscheme plugin below, and then
		-- change the command in the config to whatever the name of that colorscheme is.
		--
		-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
		"folke/tokyonight.nvim",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		init = function()
			-- Load the colorscheme here.
			-- Like many other themes, this one has different styles, and you could load
			-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
			vim.cmd.colorscheme("tokyonight-night")

			-- You can configure highlights by doing something like:
			vim.cmd.hi("Comment gui=none")
		end,
	}, ]]
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		init = function()
			require("catppuccin").setup({
				-- flavour = "mocha", -- latte, frappe, macchiato, mocha
				flavour = "macchiato", -- latte, frappe, macchiato, mocha
				background = { -- :h background
					light = "latte",
					dark = "mocha",
				},
				transparent_background = false, -- disables setting the background color.
				show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
				term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
				dim_inactive = {
					enabled = false, -- dims the background color of inactive window
					shade = "dark",
					percentage = 0.15, -- percentage of the shade to apply to the inactive window
				},
				no_italic = false, -- Force no italic
				no_bold = false, -- Force no bold
				no_underline = false, -- Force no underline
				styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
					comments = { "italic" }, -- Change the style of comments
					conditionals = { "italic" },
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
					operators = {},
					-- miscs = {}, -- Uncomment to turn off hard-coded styles
				},
				highlight_overrides = {
					macchiato = function(colors)
						return {
							CurSearch = { bg = colors.sky },
							IncSearch = { bg = colors.sky },
							CursorLineNr = { fg = colors.blue, style = { "bold" } },
							DashboardFooter = { fg = colors.overlay0 },
							TreesitterContextBottom = { style = {} },
							WinSeparator = { fg = colors.overlay0, style = { "bold" } },
							["@markup.italic"] = { fg = colors.blue, style = { "italic" } },
							["@markup.strong"] = { fg = colors.blue, style = { "bold" } },
							Headline = { style = { "bold" } },
							Headline1 = { fg = colors.blue, style = { "bold" } },
							Headline2 = { fg = colors.pink, style = { "bold" } },
							Headline3 = { fg = colors.lavender, style = { "bold" } },
							Headline4 = { fg = colors.green, style = { "bold" } },
							Headline5 = { fg = colors.peach, style = { "bold" } },
							Headline6 = { fg = colors.flamingo, style = { "bold" } },
							rainbow1 = { fg = colors.blue, style = { "bold" } },
							rainbow2 = { fg = colors.pink, style = { "bold" } },
							rainbow3 = { fg = colors.lavender, style = { "bold" } },
							rainbow4 = { fg = colors.green, style = { "bold" } },
							rainbow5 = { fg = colors.peach, style = { "bold" } },
							rainbow6 = { fg = colors.flamingo, style = { "bold" } },
						}
					end,
				},
				color_overrides = {
					macchiato = {
						rosewater = "#F5B8AB",
						flamingo = "#F29D9D",
						pink = "#AD6FF7",
						mauve = "#FF8F40",
						red = "#E66767",
						maroon = "#EB788B",
						peach = "#FAB770",
						yellow = "#FACA64",
						green = "#70CF67",
						teal = "#4CD4BD",
						sky = "#61BDFF",
						sapphire = "#4BA8FA",
						blue = "#00BFFF",
						lavender = "#00BBCC",
						text = "#C1C9E6",
						subtext1 = "#A3AAC2",
						subtext0 = "#8E94AB",
						overlay2 = "#7D8296",
						overlay1 = "#676B80",
						overlay0 = "#464957",
						surface2 = "#3A3D4A",
						surface1 = "#2F313D",
						surface0 = "#1D1E29",
						base = "#0b0b12",
						mantle = "#11111a",
						crust = "#191926",
					},
				},
				default_integrations = true,
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					treesitter = true,
					notify = false,
					mini = {
						enabled = true,
						indentscope_color = "",
					},
					-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
				},
			})

			-- setup must be called before loading
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	--[[ {
		"bluz71/vim-nightfly-colors",
		name = "nightfly",
		lazy = false,
		priority = 1000,
		init = function()
			vim.cmd.colorscheme("nightfly")
		end,
	}, ]]
}
