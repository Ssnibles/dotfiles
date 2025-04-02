# Run fastfetch as welcome message
function fish_greeting
    fastfetch --config ~/.config/fastfetch/presets/pokemon.jsonc
end

function fetch
    fish_greeting # Run fish_greeting function when using fetch
end
