set -gx EDITOR nvim
set -gx VISUAL nvim

# Format man pages
set -x MANROFFOPT "-c"
set -x MANPAGER "sh -c "col -bx | bat -l man -p""

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low

set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
