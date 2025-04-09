return {
  -- enabled = false,
  "j-hui/fidget.nvim",
  event = "LspAttach",
  opts = {
    notification = {
      window = {
        winblend = 0,
        border = "none",
        zindex = 45,
        max_width = 0,
        max_height = 0,
        x_padding = 0,
        y_padding = 0,
        align = "bottom",
        relative = "editor",
      },
    },
    progress = {
      ignore = { "^null-ls" },
      suppress_on_insert = true,
      ignore_done_already = true,
      ignore_empty_message = true,
    },
    display = {
      done_ttl = 3,
      done_icon = "✔",
      done_style = "Constant",
      progress_icon = { "dots" },
    },
    view = { stack_upwards = true },
  },
}
