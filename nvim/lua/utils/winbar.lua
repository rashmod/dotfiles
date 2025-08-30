local M = {}

-- Get the root directory: LSP root > Git root > current file dir
local function get_workspace_root()
	local clients = vim.lsp.get_active_clients({ bufnr = 0 })
	for _, client in ipairs(clients) do
		local workspace_folders = client.config.workspace_folders
		if workspace_folders then
			return vim.uri_to_fname(workspace_folders[1].uri)
		elseif client.config.root_dir then
			return client.config.root_dir
		end
	end

	-- fallback to Git root
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if git_root and git_root ~= "" then
		return git_root
	end

	-- fallback to directory of current file
	return vim.fn.expand("%:p:h")
end

function M.file_path()
	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname == "" or vim.bo.buftype ~= "" or vim.bo.filetype == "" then
		return ""
	end

	local ignore_filetypes = {
		NvimTree = true,
		TelescopePrompt = true,
		alpha = true,
		help = true,
		terminal = true,
	}

	if ignore_filetypes[vim.bo.filetype] then
		return ""
	end

	local file = vim.fn.expand("%:p") -- absolute path to file
	local root = get_workspace_root()

	if file:find(root, 1, true) == 1 then
		file = file:sub(#root + 2)
	end

	local path = file:gsub("/", " > ")
	local max_len = 80
	if #path > max_len then
		path = "… > " .. path:sub(#path - max_len + 6)
	end

	local devicons = require("nvim-web-devicons")
	local icon, _ = devicons.get_icon(vim.fn.expand("%:t"), vim.fn.expand("%:e"), { default = true })
	return "%#WinBarPath#" .. icon .. " " .. path
end

return M
