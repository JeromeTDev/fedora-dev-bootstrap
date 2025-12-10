return {

  -------------------------------------------------------------------
  -- CODECOMPANION
  -------------------------------------------------------------------
  {
    "olimorris/codecompanion.nvim",
    version = "v17.33.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },

    config = function()
      local cc = require("codecompanion")

      cc.setup({
        strategies = {
          chat = {
            adapter = "ollama",
            prompt_prefix = "Bitte antworte ausschließlich auf Deutsch:\n\n",
            window = { wrap = true, syntax_highlight = true },
          },
          inline = {
            adapter = "ollama",
            prompt_prefix = "Bitte erkläre oder verbessere folgenden Code auf Deutsch:\n\n",
            schema = {
              temperature = 0.2,
              max_tokens = 300,
            },
          },
        },
        adapters = {
          ollama = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                url = "http://localhost:1234/v1",
                api_key = "dummy",
              },
            })
          end,
        },
      })

      -------------------------------------------------------------------
      -- 🔥 KEYMAPS (CodeCompanion)
      -------------------------------------------------------------------
      local map = vim.keymap.set

      -- Hauptmenü
      map({ "n", "v" }, "<leader>a", "", { desc = "AI" })

      -- CodeCompanion
      map("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "CC Chat" })
      map("n", "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "CC Inline Edit" })
      map({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "CC Actions" })
      map("n", "<leader>cl", "<cmd>CodeCompanionInline<cr>", { desc = "CC Inline Line" })
      map("v", "<leader>ce", "<cmd>CodeCompanionActions<cr>", { desc = "CC Actions (Selection)" })
    end,
  },

  -------------------------------------------------------------------
  -- OPENCODE (unter <leader>a Menü einsortiert)
  -------------------------------------------------------------------
  {
    "NickvanDyke/opencode.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },

    config = function()
      local op = require("opencode")
      local map = vim.keymap.set
      -- Required for `opts.events.reload`.
      vim.o.autoread = true

      -------------------------------------------------------------------
      -- 🔥 OpenCode Keymaps unter <leader>a
      -------------------------------------------------------------------
      -- Ask (Cursor oder Visual)
      map({ "n", "x" }, "<leader>ao", function()
        op.ask("@this: ", { submit = true })
      end, { desc = "OC Ask" })

      -- Toggle Chat
      map("n", "<leader>at", function()
        op.toggle()
      end, { desc = "OC Toggle" })

      -- Edit
      map({ "n", "x" }, "<leader>ae", function()
        op.edit()
      end, { desc = "OC Edit" })

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
  },
}
