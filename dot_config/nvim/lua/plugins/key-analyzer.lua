return {
	"meznaric/key-analyzer.nvim",
	opts = {
		command_name = "KeyAnalyzer", -- or nil to disable the command

		-- Customize the highlight groups
		highlights = {
			bracket_used = "KeyAnalyzerBracketUsed",
			letter_used = "KeyAnalyzerLetterUsed",
			bracket_unused = "KeyAnalyzerBracketUnused",
			letter_unused = "KeyAnalyzerLetterUnused",
			promo_highlight = "KeyAnalyzerPromo",

			-- Set to false if you want to define highlights manually
			define_default_highlights = true,
		},

		-- Keyboard layout to use
		-- Available options are: qwerty, colemak, colemak-dh
		layout = "qwerty",
	},
}
