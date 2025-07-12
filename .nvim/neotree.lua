require("neo-tree").setup({
	filesystem = {
		filtered_items = {
			hide_dotfiles = true,
			hide_gitignored = true,
			hide_by_pattern = {
				"*.uid",
				"*.tres",
				"*.tscn",
				"*.import",
			},
		},
	},
})
