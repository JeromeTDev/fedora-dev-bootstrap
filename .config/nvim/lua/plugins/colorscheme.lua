return {
  {
    "sainnhe/gruvbox-material",
    priority = 1000,
    config = function()
      ------------------------------------------------------------
      -- Gruvbox Material Setup
      ------------------------------------------------------------
      -- vim.g.gruvbox_material_background = "soft"
      -- vim.g.gruvbox_material_foreground = "soft"
      vim.g.gruvbox_material_palette = "material"

      vim.g.gruvbox_material_ui_contrast = "medium"
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_enable_bold = true
      -- Hintergrund für Popups
      vim.g.gruvbox_material_transparent_background = false
      vim.g.gruvbox_material_better_performance = false
      vim.g.gruvbox_material_dim_inactive_windows = true

      vim.g.gruvbox_material_statusline_style = "afterglow" -- Options: "original", "material", "mix", "afterglow"
      ------------------------------------------------------------
      -- Colorscheme laden
      ------------------------------------------------------------
      vim.cmd("colorscheme gruvbox-material")

      ------------------------------------------------------------
      -- Transparente Floating Windows
      ------------------------------------------------------------
      local float_bg = "none"

      vim.api.nvim_set_hl(0, "NormalFloat", { bg = float_bg })
      vim.api.nvim_set_hl(0, "FloatBorder", { bg = float_bg })

      vim.api.nvim_set_hl(0, "NotifyBackground", { bg = float_bg })
      vim.api.nvim_set_hl(0, "NoicePopup", { bg = float_bg })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = float_bg })
      vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { bg = float_bg })

      ------------------------------------------------------------
      -- leichte Anpassungen fürs Popupmenu
      ------------------------------------------------------------
      vim.api.nvim_set_hl(0, "Pmenu", { bg = float_bg })
      vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#3c3836" }) -- etwas dunklerer highlight

      -- Custom statusline highlights
      -- vim.api.nvim_set_hl(0, "StatusLine", {
      --   bg = "#1C2021", -- Dark gray background
      --   fg = "#ebdbb2", -- Light text
      --   bold = false
      -- })
      --
      vim.api.nvim_set_hl(0, "StatusLineNC", {
        bg = "#1C2021", -- Darker background for inactive windows
        fg = "#928374", -- Muted text
        bold = false,
      })
    end,
  },
}
