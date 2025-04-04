return {
  -- TODO:
  "j-hui/fidget.nvim",
  event = "LspAttach",
  opts = {
    notification = {
      window = {
        winblend = 0,
        border = "none", -- Border around the notification window
        zindex = 45, -- Stacking priority of the notification window
        max_width = 0, -- Maximum width of the notification window
        max_height = 0, -- Maximum height of the notification window
        x_padding = 1, -- Padding from right edge of window boundary
        y_padding = 0, -- Padding from bottom edge of window boundary
        align = "bottom", -- How to align the notification window
        relative = "editor", -- What the notification window position is relative to
      },
    },
    progress = {
      ignore = { "^null-ls" },
      suppress_on_insert = true, -- Suppress new messages while in insert mode
      ignore_done_already = true, -- Ignore new tasks that are already complete
      ignore_empty_message = true, -- Ignore new tasks that don't contain a message
    },
    display = {
      done_ttl = 3, -- How long a message should be shown after done
      done_icon = "✔", -- Icon shown when all LSP progress tasks are complete
      done_style = "Constant", -- Highlight group for completed LSP tasks
      progress_icon = { "dots" }, -- Icon shown when LSP progress tasks are in progress
    },
    view = {
      stack_upwards = true,
    },
  },
}
