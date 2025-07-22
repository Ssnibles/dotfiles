# Base background and foreground colors
set -Ux FZF_COLOR_BG "{{colors.background.default.hex}}"
set -Ux FZF_COLOR_BG_PLUS "{{colors.secondary.default.hex}}"
set -Ux FZF_COLOR_FG "{{colors.secondary.default.hex}}"

# Highlight colors for matched text
set -Ux FZF_COLOR_HL "{{colors.primary.default.hex}}"
set -Ux FZF_COLOR_HL_PLUS "{{colors.primary.default.hex}}"

# Colors for UI elements
set -Ux FZF_COLOR_HEADER "{{colors.secondary.default.hex}}"
set -Ux FZF_COLOR_INFO "{{colors.secondary.default.hex}}"
set -Ux FZF_COLOR_PROMPT "{{colors.tertiary.default.hex}}"
set -Ux FZF_COLOR_SPINNER "{{colors.secondary.default.hex}}"

# Colors for selection and multi-select markers
set -Ux FZF_COLOR_POINTER "{{colors.secondary.default.hex}}"
set -Ux FZF_COLOR_MARKER "{{colors.primary.default.hex}}"

# Background for selected item (often a subtle variation of the main background)
set -Ux FZF_COLOR_BG_PLUS "{{colors.background.default.hex}}"

# Border color (consider a slightly darker or complementary shade)
set -Ux FZF_COLOR_BORDER "{{colors.surface_bright.default.hex}}"
