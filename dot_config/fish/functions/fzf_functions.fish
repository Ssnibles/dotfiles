# --- Rosé Pine Theme Colors
set -Ux FZF_ROSEPINE_BG        "#191724"
set -Ux FZF_ROSEPINE_BG_PLUS   "#2a273f"
set -Ux FZF_ROSEPINE_FG        "#e0def4"
set -Ux FZF_ROSEPINE_FG_PLUS   "#e0def4"
set -Ux FZF_ROSEPINE_HL        "#eb6f92"
set -Ux FZF_ROSEPINE_HL_PLUS   "#f6c177"
set -Ux FZF_ROSEPINE_HEADER    "#9ccfd8"
set -Ux FZF_ROSEPINE_INFO      "#c4a7e7"
set -Ux FZF_ROSEPINE_POINTER   "#ebbcba"
set -Ux FZF_ROSEPINE_MARKER    "#f6c177"
set -Ux FZF_ROSEPINE_PROMPT    "#9ccfd8"
set -Ux FZF_ROSEPINE_SPINNER   "#f6c177"
set -Ux FZF_ROSEPINE_BORDER    "#393552"

set -x FZF_THEME_COLORS "\
--color=bg+:$FZF_ROSEPINE_BG,bg:$FZF_ROSEPINE_BG,spinner:$FZF_ROSEPINE_SPINNER,hl:$FZF_ROSEPINE_HL,fg:$FZF_ROSEPINE_FG \
--color=header:$FZF_ROSEPINE_HEADER,info:$FZF_ROSEPINE_INFO,pointer:$FZF_ROSEPINE_POINTER,marker:$FZF_ROSEPINE_MARKER \
--color=fg+:$FZF_ROSEPINE_FG,prompt:$FZF_ROSEPINE_PROMPT,hl+:$FZF_ROSEPINE_HL"

set -x FZF_DEFAULT_OPTS "$FZF_THEME_COLORS \
--border=rounded --margin=1,2 --padding=1 \
--preview-window='right:60%:rounded:hidden:border-bold' \
--scrollbar='█' --separator='·' \
--ansi --cycle --layout=reverse --prompt=' ' --pointer='➜' --marker='✓' \
--bind=tab:down,btab:up,ctrl-space:toggle,shift-up:preview-up,shift-down:preview-down \
--height=80% --multi --info=inline"

set -Ux FZF_BAT_PREVIEW 'bat --style=numbers --color=always --theme="base16" --line-range :500 {} 2>/dev/null || cat {}'

# --- Enhanced File Opener ---
function fzf_open
    set -l selected_file (fzf --preview="$FZF_BAT_PREVIEW" --prompt="󰈔 Open: " --header="Select a file to open")
    if test -n "$selected_file"
        commandline -i -- (string escape -- "$selected_file")
    end
    commandline -f repaint
end

# --- File Search and Edit ---
function fe
    set -l query (string escape -- "$argv[1]")
    set -l file (fzf --query="$query" --select-1 --exit-0 \
        --prompt="󰈙 Edit: " \
        --header="Type to search files" \
        --preview="$FZF_BAT_PREVIEW")
    if test -n "$file"
        set -l editors nvim vim vi nano
        for editor in $editors
            if command -q "$editor"
                command "$editor" "$file"
                return
            end
        end
        echo "No suitable editor found. Install neovim or modify the fe function."
        return 1
    end
    echo "No file selected."
    return 1
end

# --- Directory Search ---
function fcd
    set -l dir (fd --type d --hidden --exclude .git | fzf \
        --prompt=" Dir: " \
        --header="Select a directory" \
        --preview='tree -C {} 2>/dev/null || eza --tree --icons {} || exa --tree --icons {} || ls -1 --color {} | head -200' \
        --preview-window='right:60%:rounded:border-bold')
    if test -n "$dir"
        cd "$dir"
        commandline -f repaint
        ls
    end
end

# --- Command History Search ---
function fh
    history --null | fzf --read0 --tac \
        --prompt="󰄉 History> " \
        --header="Search command history" \
        --preview='echo - {} | fish_indent --ansi | bat --language fish --color=always --theme="base16"' \
        --preview-window='right:60%:wrap' | read -l result
    and commandline -- "$result"
    commandline -f repaint
end

# --- Process Killer ---
function fkill
    set -l pid (ps -eo pid,user,command | \
        fzf --prompt="󰈸 Kill: " --header='[Kill Process]' --header-first --with-nth=2.. \
        --preview='echo "PID: {1}\nUSER: {2}\nCOMMAND: {3..}"' \
        --preview-window='down:3:wrap' | awk '{print $1}')
    if test -n "$pid"
        echo "Killing process $pid: "(ps -p "$pid" -o command=)
        command kill -9 "$pid"
    end
end

# --- Git Log Browser ---
function fgl
    git log --graph --color=always --format="%C(auto)%h %d %s %C(green)%cr %C(blue)%an" | \
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --prompt="󰊢 Git Log: " \
        --header="Browse git history" \
        --preview='git show --color=always {1} | delta --theme="base16" 2>/dev/null || git show --color=always {1} | bat --color=always --theme="base16" || git show {1} | less -R' \
        --bind "enter:execute:git show {1} | delta --theme=\"base16\" || git show {1} | less -R"
end

# --- Clipboard Copy ---
function fcp
    set -l file (fzf --prompt="󰅍 Copy: " --preview="$FZF_BAT_PREVIEW")
    if test -n "$file"
        if command -q pbcopy
            cat "$file" | pbcopy
        else if command -q xclip
            cat "$file" | xclip -selection clipboard
        else if command -q wl-copy
            cat "$file" | wl-copy
        else
            echo "No clipboard utility found (pbcopy/xclip/wl-copy)"
            return 1
        end
        echo "📋 Content of "(set_color blue)"$file"(set_color normal)" copied to clipboard"
    end
end

# --- Man Page Browser ---
function fman
    man -k . | awk -F' - ' '{printf "%-30s %s\n", $1, $2}' | \
    fzf --prompt='󰮥 Man: ' \
        --header="Search man pages" \
        --preview='echo {1} | xargs man -P cat 2>/dev/null | bat --language=man --color=always --theme="base16"' | \
    awk '{print $1}' | xargs -r man
end

# --- Function Browser ---
function fuzzy_all_functions
    set -l selected_function (functions | fzf \
        --prompt="󰊕 Func: " \
        --header="Fish Functions" \
        --preview='functions {} | fish_indent --ansi | bat --style=numbers --language fish --color=always --theme="base16"' \
        --preview-window='right:70%:wrap')
    if test -n "$selected_function"
        commandline -i -- "$selected_function"
    end
    commandline -f repaint
end

# --- Modern Aliases (eza/exa) ---
if command -q eza
    alias l 'eza -l --icons --git --group-directories-first --time-style=long-iso --color-scale'
    alias ll 'eza -la --icons --git --group-directories-first --time-style=long-iso --color-scale'
    alias tree 'eza --tree --icons --git-ignore --level=2'
else if command -q exa
    alias l 'exa -l --icons --git --group-directories-first'
    alias ll 'exa -la --icons --git --group-directories-first'
    alias tree 'exa --tree --icons'
end
