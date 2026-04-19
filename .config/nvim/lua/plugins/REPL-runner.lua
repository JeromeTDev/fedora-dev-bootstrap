-- ~/.config/nvim/lua/plugins/iron_setup.lua
return {
  "Vigemus/iron.nvim",
  config = function()
    local iron = require("iron.core")
    local view = require("iron.view")
    local common = require("iron.fts.common")

    -- IPython falls verfügbar, sonst python3
    local python_cmd = vim.fn.executable("ipython") == 1 and "ipython" or "python3"

    -- Leader für REPL toggle
    vim.keymap.set("n", "<leader>p", function()
      iron.toggle_repl()
    end, { desc = "🐍 REPL", silent = true })

    iron.setup({
      config = {
        scratch_repl = true,
        repl_definition = {
          python = {
            command = { python_cmd, "--quiet" },
            format = common.bracketed_paste_python,
            block_dividers = { "# %%", "#%%" }, -- Jupyter-Style Zellen
          },
          java = { command = { "jshell" } },
          cs = { command = { "dotnet", "interactive" } },
          c = { command = { "bash", "-c", "gcc % -o /tmp/a.out && /tmp/a.out" } },
          sagemath = { command = { "sage", "-python" } },
        },
        repl_filetype = function(_, ft)
          return ft
        end,
        dap_integration = true,
        repl_open_cmd = view.bottom(10),
      },

      keymaps = {
        toggle_repl = "<leader>pt",
        restart_repl = "<leader>pR",
        send_motion = "<leader>ps",
        visual_send = "<leader>ps",
        send_file = "<leader>pr",
        send_line = "<leader>pl",
        send_paragraph = "<leader>pp",
        send_until_cursor = "<leader>pu",
        send_mark = "<leader>pm",
        send_code_block = "<leader>pb",
        send_code_block_and_move = "<leader>pn",
        mark_motion = "<leader>pmc",
        mark_visual = "<leader>pmc",
        remove_mark = "<leader>pmd",
        cr = "<leader>p<cr>",
        interrupt = "<leader>pi",
        exit = "<leader>pq",
        clear = "<leader>pc", -- optional: iron.send("!clear\n") im REPL nutzen
      },
      highlight = { italic = true },
      ignore_blank_lines = true,
    })

    -- Sage-Dateien automatisch als Python erkennen
    vim.filetype.add({
      extension = {
        sage = "python",
      },
    })
  end,
}
