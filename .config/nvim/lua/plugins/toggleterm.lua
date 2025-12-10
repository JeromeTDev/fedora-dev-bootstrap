-- ~/.config/nvim/lua/plugins/toggleterm.lua
return {
  "akinsho/toggleterm.nvim",
  opts = {
    direction = "float",
    -- open_mapping = [[<C-^>]],
    open_mapping = { [[<c-\>]], [[<c-'>]] },

    shade_terminals = true,
    shading_factor = 2,

    on_open = function(term)
      vim.cmd("startinsert")
      term:send("cd " .. vim.fn.getcwd() .. "\n")
    end,

    float_opts = {
      border = "rounded",
      width = math.floor(vim.o.columns * 0.8),
      height = math.floor(vim.o.lines * 0.8),
    },
  },
}
