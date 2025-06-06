# bind \cl 'clear; commandline -f repaint'
# bind \cx 'echo "Hello, Fish!"'

bind \ct tmux
bind \cn nvim

# Unbind keys
function fish_user_key_bindings
    bind --erase --preset \ev
    # Add more unbinds as needed
end
