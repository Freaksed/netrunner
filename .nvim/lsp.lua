local project_root = vim.fn.getcwd()

local jsonls_config = {
	settings = {
		json = {
			schemas = {
				{
					description = "Root Schema",
					fileMatch = { "cards/data/**/*.json" },
					url = "file://" .. project_root .. "/schemas/root.schema.json",
				},
			},
			validate = { enable = true },
		},
	},
}

require("lspconfig").jsonls.setup(jsonls_config)
