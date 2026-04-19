-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.autosave")
require("config.options")
require("config.runners")

-- Diese Funktion entfernt den Hintergrund von Neovim
local function clear_bg()
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" }) -- Für inaktive Fenster
  vim.api.nvim_set_hl(0, "MsgArea", { bg = "none" })
end

-- Muss nach dem Laden des Themes ausgeführt werden
clear_bg()

-- Falls du das Theme wechselst, wird der Hintergrund wieder transparent gemacht
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = clear_bg,
})
