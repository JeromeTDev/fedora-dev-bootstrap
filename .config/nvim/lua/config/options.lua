-- Optionen werden automatisch vor dem Start von lazy.nvim geladen
-- Standardoptionen: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
--
-- auskommentierte Optionen sind schon standart bei lazyvim -> dienen für reines vanilla Nvim

-- ==============================
-- 📝 RECHTSCHREIBUNG
-- ==============================
vim.opt.spell = false -- Rechtschreibprüfung deaktivieren
vim.opt.spelllang = { "en", "de" } -- Sprachen für Rechtschreibprüfung

-- ==============================
-- 📄 ZEILENUMBRUCH / TEXTDARSTELLUNG
-- ==============================
vim.opt.wrap = true -- Lange Zeilen umbrechen
vim.opt.linebreak = true -- Beim Umbrechen Wörter nicht teilen
vim.opt.breakindent = true -- Umgebrochene Zeilen behalten Einrückung

-- ==============================
-- 🖥️ UI / TABS / FENSTER
-- ==============================
vim.opt.showtabline = 0 -- Klassische Tab-Leiste ausblenden
-- vim.opt.splitbelow = true                   -- Neue horizontale Splits unten öffnen
-- vim.opt.splitright = true                   -- Neue vertikale Splits rechts öffnen
-- vim.opt.termguicolors = true                -- Verbesserte Farbdarstellung aktivieren
-- vim.opt.title = true                        -- Fenstertitel anzeigen

-- ==============================
-- ↹ EINRÜCKUNG & TABS
-- ==============================
-- vim.opt.shiftwidth = 2                      -- Automatische Einrückung = 2 Leerzeichen
-- vim.opt.expandtab = true                    -- TAB-Taste erzeugt Leerzeichen statt Tab-Zeichen
vim.opt.tabstop = 2 -- Darstellung eines Tab-Zeichens als 2 Leerzeichen
-- ==============================
-- ⚡ PERFORMANCE
-- ==============================
vim.opt.updatetime = 100 -- Schnellere Update-Intervalle für Plugins

-- ==============================
-- 💾 UNDO / BACKUP / SWAP
-- ==============================
vim.opt.undofile = true -- Änderungen dauerhaft rückgängig machen können
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo" -- Speicherort für Undo-Dateien
-- vim.opt.backup = false                      -- Keine Backup-Dateien erstellen
-- vim.opt.swapfile = false                    -- Keine Swap-Dateien erstellen
-- vim.opt.writebackup = false                 -- Kein Backup beim Schreiben erstellen

-- ==============================
-- 🧾 ZEILENNUMMERN / SIGNCOLUMN
-- ==============================
-- vim.opt.number = true                       -- Zeilennummern anzeigen
-- vim.opt.relativenumber = true               -- Relative Zeilennummern anzeigen
-- vim.opt.signcolumn = "yes:1"                -- Extra-Spalte für LSP/Git-Symbole

-- ==============================
-- 🖱️ MAUS
-- ==============================
-- vim.opt.mouse = "a"                         -- Maus überall aktivieren

-- ==============================
-- 🔍 SUCHE
-- ==============================
-- vim.opt.ignorecase = true                   -- Groß-/Kleinschreibung ignorieren
-- vim.opt.incsearch = true                    -- Ergebnisse während Eingabe anzeigen
-- vim.opt.smartcase = true                    -- Großbuchstaben erzwingen genaue Suche

-- ==============================
-- 📋 CLIPBOARD
-- ==============================
-- vim.opt.clipboard = "unnamedplus"           -- System-Zwischenablage verwenden
