return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")

    opts.window = {
      completion = cmp.config.window.bordered({
        border = "rounded",
      }),
      documentation = cmp.config.window.bordered({
        border = "rounded",
      }),
    }
  end,
}
