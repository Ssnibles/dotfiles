# Rosé Pine Moon fzf theme with enhanced UI
set -Ux FZF_DEFAULT_OPTS "\
--color=bg+:#393552,bg:#232136,spinner:#f6c177,hl:#ea9a97,fg:#e0def4 \
--color=header:#3e8fb0,info:#9ccfd8,pointer:#c4a7e7,marker:#f6c177 \
--color=fg+:#e0def4,prompt:#9ccfd8,hl+:#ea9a97 \
--border=rounded --margin=1 --padding=1 \
--preview-window='right:60%:border-sharp' \
--scrollbar=' ' --separator=' ' \
--ansi --cycle --layout=reverse --pointer=' ' --marker=' ' \
--bind=tab:down,btab:up,ctrl-space:toggle,shift-up:preview-up,shift-down:preview-down \
--height=80% --multi --info=inline"

# Enhanced file opener with bat fallback
function fzf_open
    set -l preview_cmd 'bat --style=numbers --color=always --theme="base16" --line-range :500 {} 2>/dev/null || cat {}'
    set -l selected_file (fzf --preview "$preview_cmd")
    if test -n "$selected_file"
        commandline -i -- (string escape -- "$selected_file")
    end
    commandline -f repaint
end

# File search and edit with editor fallback
function fe
    set -l query (string escape -- "$argv[1]")
    set -l file (fzf --query="$query" --select-1 --exit-0 \
        --preview 'bat --style=numbers --color=always --theme="base16" --line-range :500 {} 2>/dev/null || cat {}')
    
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

# Directory search with tree/exa fallback
function fcd
    set -l dir (fd --type d --hidden --exclude .git | fzf \
        --preview 'tree -C {} 2>/dev/null || exa --tree --icons {} || ls -1 --color {} | head -200')
    
    if test -n "$dir"
        cd "$dir"
        commandline -f repaint
        ls
    end
end

# Command history search with better preview
function fh
    history --null | fzf --read0 --tac \
        --preview 'echo - {} | fish_indent --ansi | bat --language fish --color=always --theme="base16"' \
        --preview-window 'right:60%:wrap' | read -l result
    and commandline -- "$result"
    commandline -f repaint
end

# Process killer with safety check
function fkill
    set -l pid (ps -eo pid,user,command | \
        fzf --header='[Kill Process]' --header-first --with-nth=2.. \
        --preview 'echo "PID: {1}\nUSER: {2}\nCOMMAND: {3..}"' \
        --preview-window 'down:3:wrap' | awk '{print $1}')
    
    if test -n "$pid"
        echo "Killing process $pid: "(ps -p "$pid" -o command=)
        command kill -9 "$pid"
    end
end

# Git log browser with delta support
function fgl
    git log --graph --color=always --format="%C(auto)%h %d %s %C(green)%cr %C(blue)%an" | \
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview 'git show --color=always {1} | delta --theme="base16" 2>/dev/null || git show --color=always {1}' \
        --bind "enter:execute:git show {1} | delta --theme=\"base16\" || git show {1} | less -R"
end

# Cross-platform clipboard copy
function fcp
    set -l file (fzf --preview 'bat --style=numbers --color=always --theme="base16" --line-range :500 {}')
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

# Improved man page browser
function fman
    man -k . | awk -F' - ' '{printf "%-30s %s\n", $1, $2}' | \
    fzf --prompt='Man> ' \
        --preview 'echo {1} | xargs man -P cat 2>/dev/null | bat --language=man --color=always --theme="base16"' | \
    awk '{print $1}' | xargs -r man
end

# Function browser with better preview
function fuzzy_all_functions
    set -l selected_function (functions | fzf \
        --header 'Fish Functions' \
        --preview 'functions {} | fish_indent --ansi | bat --style=numbers --language fish --color=always --theme="base16"' \
        --preview-window 'right:70%:wrap')
    
    if test -n "$selected_function"
        commandline -i -- "$selected_function"
    end
    commandline -f repaint
end

# Smart context-aware fzf with TMUX support
function smart_fzf
    if set -q TMUX
        set -l height (math "min(80, $(tmux display-message -p '#{window_height}') - 4")
        set -f fzf_height "--height=$height%"
    else
        set -f fzf_height "--height=80%"
    end  # <-- This was missing in your version

    switch (commandline -t)
        case kill '*'
            fkill
        case nvim\* vim\* nano\* code\*
            fe
        case ssh\* scp\* sftp\*
            set -l host (rg '^Host' ~/.ssh/config | awk '{print $2}' | sort | fzf $fzf_height)
            test -n "$host" && commandline -i -- "$host"
        case cd\*
            fcd
        case git\*
            switch (commandline -t | string split ' ')
                case git
                    set -l subcmd (git --list-cmds=main,others,alias,config | fzf $fzf_height)
                    test -n "$subcmd" && commandline -i -- "$subcmd "
                case 'git checkout'*
                    set -l branch (git branch --format='%(refname:short)' | fzf $fzf_height)
                    test -n "$branch" && commandline -i -- "$branch"
                case '*'
                    fgl
            end
        case man\*
            fman
        case '*'
            fzf_open
    end
    commandline -f repaint
end

# Bind Ctrl-F with fallback for different terminal types
bind \cf smart_fzf 2>/dev/null || bind \ct smart_fzf

# Unified fuzzy helper
function fuzzy
    set -l fuzzy_functions fzf_open fe fcd fh fkill fgl fcp fman smart_fzf fuzzy_all_functions
    set -l function_name (printf '%s\n' $fuzzy_functions | fzf \
        --header 'FZF Functions' \
        --preview 'functions {} | fish_indent --ansi | bat --language fish --color=always --theme="base16"' \
        --preview-window 'right:70%:wrap')
    
    if test -n "$function_name"
        echo -n (set_color brblue)"$function_name"(set_color normal)" - "
        read -l -P "View [v], Run [r], or Cancel [c]: " choice
        switch (string lower "$choice")
            case v
                functions "$function_name" | fish_indent --ansi | bat --language fish --paging always
            case r
                eval "$function_name"
            case '*'
                echo "Operation cancelled."
        end
    end
end

# Modern aliases with exa replacement (eza)
if command -q eza
    alias l 'eza -l --icons --git --group-directories-first --time-style=long-iso --color-scale'
    alias ll 'eza -la --icons --git --group-directories-first --time-style=long-iso --color-scale'
    alias tree 'eza --tree --icons --git-ignore --level=2'
else if command -q exa
    alias l 'exa -l --icons --git --group-directories-first'
    alias ll 'exa -la --icons --git --group-directories-first'
    alias tree 'exa --tree --icons'
end
