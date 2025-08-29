# ~/.config/fish/fzf.fish

# --- FZF Theme Configuration ---
# Set default theme variables. This acts as a fallback.
set -Ux FZF_COLOR_BG "#282A36"
set -Ux FZF_COLOR_BG_PLUS "#44475A"
set -Ux FZF_COLOR_FG "#F8F8F2"
set -Ux FZF_COLOR_FG_PLUS "#F8F8F2"
set -Ux FZF_COLOR_HL "#BD93F9"
set -Ux FZF_COLOR_HL_PLUS "#FFB86C"
set -Ux FZF_COLOR_HEADER "#50FA7B"
set -Ux FZF_COLOR_INFO "#FF79C6"
set -Ux FZF_COLOR_POINTER "#FF79C6"
set -Ux FZF_COLOR_MARKER "#FFB86C"
set -Ux FZF_COLOR_PROMPT "#50FA7B"
set -Ux FZF_COLOR_SPINNER "#FFB86C"
set -Ux FZF_COLOR_BORDER "#6272A4"

# Source the active theme if it exists.
# This will override any variables defined above.
if test -f ~/.config/fish/active_fzf_theme.fish
    source ~/.config/fish/active_fzf_theme.fish
end

# --- Construct FZF_DEFAULT_OPTS ---
# Use the theme colors, which are either defaults or sourced values.
set -x FZF_THEME_COLORS "\
--color=bg+:$FZF_COLOR_BG_PLUS,bg:$FZF_COLOR_BG,spinner:$FZF_COLOR_SPINNER,hl:$FZF_COLOR_HL,fg:$FZF_COLOR_FG \
--color=header:$FZF_COLOR_HEADER,info:$FZF_COLOR_INFO,pointer:$FZF_COLOR_POINTER,marker:$FZF_COLOR_MARKER \
--color=fg+:$FZF_COLOR_FG_PLUS,prompt:$FZF_COLOR_PROMPT,hl+:$FZF_COLOR_HL_PLUS,border:$FZF_COLOR_BORDER"

set -x FZF_DEFAULT_OPTS "$FZF_THEME_COLORS \
--border=rounded --margin=1,2 --padding=1 \
--preview-window='right:60%:rounded:hidden:border-bold' \
--scrollbar='█' --separator='·' \
--ansi --cycle --layout=reverse --prompt=' ' --pointer='➜' --marker='✓' \
--bind=tab:down,btab:up,ctrl-space:toggle,shift-up:preview-up,shift-down:preview-down \
--height=80% --multi --info=inline"

# --- Preview Command Configuration ---
# This variable is fine as is, but keeping it grouped is good practice.
set -Ux FZF_BAT_PREVIEW 'bat --style=numbers --color=always --theme="base16" --line-range :500 {} 2>/dev/null || cat {}'
