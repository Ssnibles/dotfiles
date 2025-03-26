return {
  "monaqa/dial.nvim",
  keys = {
    -- Normal Mode
    {
      "<A-Up>", -- Fixed missing '>' at the end
      function()
        require("dial.map").manipulate("increment", "normal")
      end,
      mode = { "n" },
      desc = "Increment (normal)",
    },
    {
      "<A-Down>",
      function()
        require("dial.map").manipulate("decrement", "normal")
      end,
      mode = { "n" },
      desc = "Decrement (normal)",
    },
    -- Group-wise Normal Mode (added 'g' prefix for differentiation)
    {
      "g<A-Up>", -- Changed to unique key combination
      function()
        require("dial.map").manipulate("increment", "gnormal")
      end,
      mode = { "n" },
      desc = "Increment (gnormal)",
    },
    {
      "g<A-Down>", -- Changed to unique key combination
      function()
        require("dial.map").manipulate("decrement", "gnormal")
      end,
      mode = { "n" },
      desc = "Decrement (gnormal)",
    },
    -- Visual Mode
    {
      "<A-Up>", -- Added angle brackets
      function()
        require("dial.map").manipulate("increment", "visual")
      end,
      mode = { "v" },
      desc = "Increment (visual)",
    },
    {
      "<A-Down>", -- Added angle brackets
      function()
        require("dial.map").manipulate("decrement", "visual")
      end,
      mode = { "v" },
      desc = "Decrement (visual)",
    },
  },
  config = function()
    require("dial").setup() -- Explicitly call setup
  end,
}
