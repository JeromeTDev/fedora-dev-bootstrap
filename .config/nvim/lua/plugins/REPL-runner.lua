-- lua/plugins/iron_setup.lua
return {
  "Vigemus/iron.nvim",
  config = function()
    local iron = require("iron.core")
    local view = require("iron.view")
    local common = require("iron.fts.common")

    iron.setup({
      config = {
        scratch_repl = true, -- REPL wird beim Schließen verworfen
        repl_definition = {
          python = { command = { "python3" }, format = common.bracketed_paste_python },
          java = { command = { "jshell" } },
          cs = { command = { "dotnet", "interactive" } },
          c = { command = { "bash", "-c", "gcc % -o /tmp/a.out && /tmp/a.out" } },
          sagemath = { command = { "sage", "-python" } },
        },
        repl_filetype = function(_, ft)
          return ft
        end, -- REPL bekommt Filetype des Buffers
        dap_integration = true,
        repl_open_cmd = view.bottom(10), -- REPL unten öffnen
        dap_integration = true, --Sorgt dafür, dass send-Befehle an nvim-dap-REPL weitergeleitet werden, falls DAP aktiv
      },
      keymaps = {
        toggle_repl = "<leader>cct", -- REPL togglen
        restart_repl = "<leader>ccR", -- REPL neu starten
        send_motion = "<leader>ccs", -- markierten Code senden
        visual_send = "<leader>ccs",
        send_file = "<leader>ccr", -- ganze Datei ausführen
        send_line = "<leader>ccl",
        send_paragraph = "<leader>ccp",
        send_until_cursor = "<leader>ccu",
        cr = "<leader>cc<cr>",
        interrupt = "<leader>cci",
        exit = "<leader>ccq",
        clear = "<leader>ccc",
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
