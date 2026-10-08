return {
  -------------------------------------------------------------------
  -- CODECOMPANION
  -------------------------------------------------------------------
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "ollama", -- nutzt automatisch alle verfügbaren LM-Studio Modelle
          },
        },
        adapters = {
          ollama = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                url = "http://127.0.0.1:1234", -- LM-Studio Server
              },
            })
          end,
        },
      })

      -- 🔥 Keymaps
      local map = vim.keymap.set
      map({ "n", "v" }, "<leader>a", "", { desc = "AI" })
      map("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Open CodeCompanion Chat" })
      map("n", "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "Inline CodeCompanion" })
      map("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })
    end,
  },

  -------------------------------------------------------------------
  -- OPENCODE
  -------------------------------------------------------------------
  {
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
} -- <--- hier die äußere return Tabelle korrekt schließen
