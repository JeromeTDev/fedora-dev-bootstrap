-- 🔥 Keymaps
local map = vim.keymap.set
map({ "n", "v" }, "<leader>a", "", { desc = "AI" })
map("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Open CodeCompanion Chat" })
map("n", "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "Inline CodeCompanion" })
map("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })

-------------------------------------------------------------------
-- OPENCODE
-------------------------------------------------------------------
return {
  "NickvanDyke/opencode.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function() -- <- hier die Klammer schließen, keine Parameter
    local op = require("opencode")
    local map = vim.keymap.set
    vim.o.autoread = true

    -- Ask (Cursor oder Visual)
    map({ "n", "x" }, "<leader>ao", function()
      op.ask("@this: ", { submit = true })
    end, { desc = "OC Ask" })

    -- Toggle OpenCode TUI
    local function opencode_tui_toggle()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" and vim.b[buf].opencode_tui then
          vim.api.nvim_win_close(win, true)
          return
        end
      end
      vim.cmd("vsplit term://opencode")
      vim.b[vim.api.nvim_get_current_buf()].opencode_tui = true
      vim.cmd("wincmd p")
    end
    map("n", "<leader>at", opencode_tui_toggle, { desc = "OC Toggle" })

    -- Actions Select
    map({ "n", "x" }, "<leader>as", function()
      op.select()
    end, { desc = "OC Actions" })

    -- Prompt hinzufügen
    map({ "n", "x" }, "<leader>ap", function()
      op.prompt("@this")
    end, { desc = "OC Add Prompt" })

    -- Scroll
    map("n", "<leader>aU", function()
      op.command("session.half.page.up")
    end, { desc = "OC Scroll Up" })

    map("n", "<leader>aD", function()
      op.command("session.half.page.down")
    end, { desc = "OC Scroll Down" })
  end,
}
