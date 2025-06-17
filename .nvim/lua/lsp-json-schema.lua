local project_root = vim.fn.getcwd()
local schema_path = project_root .. "/schema/netrunner_action_schema.json"

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				jsonls = {
					settings = {
						json = {
							schemas = {
								{
									description = "Netrunner Card Action Schema",
									fileMatch = { "card_data/**/*.json" },
									url = "file://" .. schema_path,
								},
							},
							validate = { enable = true },
						},
					},
				},
			},
		},
	},
}
