return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    { "rcarriga/nvim-notify", opts = { timeout = 10000 } },
  },
  opts = function(_, opts)
    opts.cmdline = {
      enabled = true,
      view = "cmdline_popup",
      format = {
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
        lua = { pattern = { "^:%s*lua%s+", "^:%s*=%s*" }, icon = "", lang = "lua" },
      },
    }

    opts.messages = { enabled = true, view = "notify" }
    opts.notify = { enabled = true, view = "notify" }

    opts.lsp = {
      hover = { enabled = true },
      signature = { enabled = true },
      documentation = { view = "hover" },

      -- 🔥 Dein LSP-Override hier eingebaut
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    }

    opts.presets = {
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    }

    -- Fokus-Handling
    local focused = true
    vim.api.nvim_create_autocmd("FocusGained", {
      callback = function()
        focused = true
      end,
    })

    vim.api.nvim_create_autocmd("FocusLost", {
      callback = function()
        focused = false
      end,
    })

    -- Notifications oben rechts
    opts.routes = opts.routes or {}
    table.insert(opts.routes, 1, {
      filter = { event = "notify", find = "No information available" },
      cond = function()
        return focused
      end,
      view = "notify_send",
      opts = { stop = false, replace = true },
    })

    opts.routes = opts.routes or {}

    -- Dein bereits vorhandener Route-Eintrag
    table.insert(opts.routes, 1, {
      filter = { event = "notify", find = "No information available" },
      cond = function()
        return focused
      end,
      view = "notify_send",
      opts = { stop = false, replace = true },
    })

    -- 🔥 jdtls Progress-Filter hinzufügen
    table.insert(opts.routes, 1, {
      filter = {
        event = "lsp",
        kind = "progress",
        find = "jdtls",
      },
      opts = { skip = true },
    })

    -- Markdown interaktiv
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(event)
        vim.schedule(function()
          require("noice.text.markdown").keys(event.buf)
        end)
      end,
    })

    return opts
  end,
}
