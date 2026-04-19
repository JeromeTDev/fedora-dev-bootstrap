-- ~ /.config/nvim/lua/config/autosave.lua

-- Gruppe für Auto-Save
local autosave_group = vim.api.nvim_create_augroup("AutoSave", { clear = true })

-- Auto-Save beim Verlassen des Buffers oder Fensters
vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
  group = autosave_group,
  pattern = "*",
  callback = function()
    -- Nur speichern, wenn die Datei modifizierbar ist
    if vim.bo.modifiable and vim.bo.modified then
      pcall(function()
        vim.cmd("silent write")
      end)
    end
  end,
})

-- Gruppe für Format-on-Save
local format_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })

-- Formatierung direkt vor dem Speichern (BufWritePre)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = format_group,
  pattern = "*",
  callback = function()
    -- LSP-Formatter nur nutzen wenn Clients verfügbar sind
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
      pcall(function()
        vim.lsp.buf.format({ async = false })
      end)
    end
  end,
})
