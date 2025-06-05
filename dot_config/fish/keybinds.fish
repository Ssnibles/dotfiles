# bind \cl 'clear; commandline -f repaint'
# bind \cx 'echo "Hello, Fish!"'

# Unbind keys
function fish_user_key_bindings
    bind --erase --preset \ev
    # Add more unbinds as needed
end
