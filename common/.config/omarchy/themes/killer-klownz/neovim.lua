-- ██╗  ██╗██╗██╗     ██╗     ███████╗██████╗
-- ██║ ██╔╝██║██║     ██║     ██╔════╝██╔══██╗
-- █████╔╝ ██║██║     ██║     █████╗  ██████╔╝
-- ██╔═██╗ ██║██║     ██║     ██╔══╝  ██╔══██╗
-- ██║  ██╗██║███████╗███████╗███████╗██║  ██║
-- ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
--
-- ██╗  ██╗██╗      ██████╗ ██╗    ██╗███╗   ██╗███████╗
-- ██║ ██╔╝██║     ██╔═══██╗██║    ██║████╗  ██║╚══███╔╝
-- █████╔╝ ██║     ██║   ██║██║ █╗ ██║██╔██╗ ██║  ███╔╝
-- ██╔═██╗ ██║     ██║   ██║██║███╗██║██║╚██╗██║ ███╔╝
-- ██║  ██╗███████╗╚██████╔╝╚███╔███╔╝██║ ╚████║███████╗
-- ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝

return {
	{
		"bjarneo/aether.nvim",
		branch = "v2",
		name = "aether",
		priority = 1000,
		opts = {
			transparent = false,
			colors = {
				-- Background colors
				bg = "#0b0a10",
				bg_dark = "#0b0a10",
				bg_highlight = "#7a74a0",

				-- Foreground colors
				-- fg: Object properties, builtin types, builtin variables, member access, default text
				fg = "#3cfaff",
				-- fg_dark: Inactive elements, statusline, secondary text
				fg_dark = "#e6e3ff",
				-- comment: Line highlight, gutter elements, disabled states
				comment = "#7a74a0",

				-- Accent colors
				-- red: Errors, diagnostics, tags, deletions, breakpoints
				red = "#ff3c8e",
				-- orange: Constants, numbers, current line number, git modifications
				orange = "#ff3c8e",
				-- yellow: Types, classes, constructors, warnings, numbers, booleans
				yellow = "#ffe347",
				-- green: Comments, strings, success states, git additions
				green = "#2dff6a",
				-- cyan: Parameters, regex, preprocessor, hints, properties
				cyan = "#ff4fd8",
				-- blue: Functions, keywords, directories, links, info diagnostics
				blue = "#4b6cff",
				-- purple: Storage keywords, special keywords, identifiers, namespaces
				purple = "#b96bff",
				-- magenta: Function declarations, exception handling, tags
				magenta = "#b96bff",
			},
		},
		config = function(_, opts)
			require("aether").setup(opts)
			vim.cmd.colorscheme("aether")

			-- Enable hot reload
			require("aether.hotreload").setup()
		end,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "aether",
		},
	},
}

--  ,-----. ,--.   ,--.     ,--.       ,--.          ,--.
-- '  .-.  '|  | ,-|  |     |  | ,---. |  |-.  ,---. |  |-.  ,---.
-- |  | |  ||  |' .-. |,--. |  || .-. || .-. '| .-. || .-. '| .-. |
-- '  '-'  '|  |\ `-' ||  '-'  /' '-' '| `-' |' '-' '| `-' |' '-' '
--  `-----' `--' `---'  `-----'  `---'  `---'  `---'  `---'  `---'

