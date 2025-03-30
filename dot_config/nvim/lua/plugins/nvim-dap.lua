return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "leoluz/nvim-dap-go",
  },
  keys = {
    {
      "<leader>dt",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Toggle Breakpoint",
    },
    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "Continue",
    },
    {
      "<leader>dn",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<leader>di",
      function()
        require("dap").step_into()
      end,
      desc = "Step Into",
    },
    {
      "<leader>do",
      function()
        require("dap").step_out()
      end,
      desc = "Step Out",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.open()
      end,
      desc = "Open REPL",
    },
    {
      "<leader>dl",
      function()
        require("dap").run_last()
      end,
      desc = "Run Last",
    },
    {
      "<leader>dq",
      function()
        require("dap").terminate()
      end,
      desc = "Terminate",
    },
  },
  config = function()
    local dap_ok, dap = pcall(require, "dap")
    local dapui_ok, dapui = pcall(require, "dapui")
    if not dap_ok or not dapui_ok then
      return
    end

    require("dap-go").setup({
      dap_configurations = {
        {
          type = "go",
          name = "Debug",
          request = "launch",
          program = "${file}",
          showLog = false,
          dlvToolPath = vim.fn.exepath("dlv"),
        },
      },
    })

    dapui.setup({
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          position = "left",
          size = 40,
        },
        { elements = { "repl" }, position = "bottom", size = 10 },
      },
    })

    dap.listeners.before.attach.dapui_config = function()
      dapui.open({ reset = true })
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open({ reset = true })
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
      dapui.float_element("repl", { position = "center", height = 20 })
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end,
}
