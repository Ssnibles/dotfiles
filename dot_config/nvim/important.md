to see the current filetype use:
```vim
 set filetype?
 ```

formatting is configured in: ~/.config/nvim/lua/plugins/conform.lua

LSPs are configured in: ~/.config/nvim/lua/plugins/mason.lua

Autocompletion is configured in: ~/.config/nvim/lua/plugins/blink.lua

local: Declares a variable / function with local scope (within the function where it is defined)
init = function(): Executes code before a plugin loads, typically for setup.


# Breakdown of how the toggle function in snacks.dim works
```lua
if not Snacks or not Snacks.dim then
```
This checks if either `Snacks` or `Snacks.dim` is nil or false. It's a guard clause to ensure the required objects exist.

```lua
print("Snacks.dim is not available")
```
If the condition above is true, this line prints an error message.

```lua
return
```
This causes an early return from the function if Snacks.dim is not available, preventing further execution.

```lua
end
```
This ends the if statement block.

```lua
Snacks.dim.enabled = not Snacks.dim.enabled
```
This toggles the `enabled` state of `Snacks.dim` by setting it to the opposite of its current value.

```lua
Snacks.dim[Snacks.dim.enabled and "enable" or "disable"]()
```
This line calls either the `enable()` or `disable()` method on `Snacks.dim`, depending on the new `enabled` state.

```lua
print("Snacks.dim " .. (Snacks.dim.enabled and "enabled" or "disabled"))
```
This prints a status message indicating whether Snacks.dim was enabled or disabled.

```lua
end
```
This closes the anonymous function definition.

# To see what is overriding settings
launch nvim with:

nvim -V1

and use

:verbose set

to see everything which changes settings

# To Search and replace
```vim
:%s/<what_to_replace>/<what_to_replace_with>/g
```

