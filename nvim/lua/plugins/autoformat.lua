return { -- Autoformat
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	log_level = "debug",
	keys = {
		{
			"<leader>ff",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[F]ile [F]ormat",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			-- Disable "format_on_save lsp_fallback" for languages that don't
			-- have a well standardized coding style. You can add additional
			-- languages here or re-enable it for the disabled ones.
			local disable_filetypes = { c = true, cpp = true }
			local lsp_format_opt
			if disable_filetypes[vim.bo[bufnr].filetype] then
				lsp_format_opt = "never"
			else
				lsp_format_opt = "fallback"
			end
			return {
				timeout_ms = 5000,
				lsp_format = lsp_format_opt,
			}
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },
			--
			-- You can use 'stop_after_first' to run the first available formatter from the list
			javascript = { "prettierd", "prettier" },
			typescript = { "prettierd", "prettier" },
			javascriptreact = { "prettierd", "prettier" },
			typescriptreact = { "prettierd", "prettier" },
			json = { "prettierd", "prettier" },
			jsonc = { "prettierd", "prettier" },
			html = { "prettierd", "prettier", "djlint" },
			css = { "prettierd", "prettier" },
			yaml = { "prettierd", "prettier" },
			markdown = { "prettierd", "prettier" },
			python = { "isort", "black" },
			djhtml = { "djlint" },
			go = { "gofumpt", "goimports-reviser" },
			sql = { "sql-formatter", "sqlfluff" },
		},
		formatters = {
			sql_formatter = {
				command = "sql-formatter",
				args = {},
				stdin = true,
			},
		},
	},
}
