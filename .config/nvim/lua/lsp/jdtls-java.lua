local lspconfig = require("lspconfig")

lspconfig.jdtls.setup({
  flags = {
    debounce_text_changes = 1000, -- 1 Sekunde Pause
  },
  settings = {
    java = {
      validation = { enabled = false },
    },
  },
})
