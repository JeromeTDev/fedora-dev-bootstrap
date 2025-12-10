return {
  {
    "lervag/vimtex",
    ft = { "tex" },
    init = function()
      -- Zathura als PDF Viewer
      vim.g.vimtex_view_method = "zathura"

      -- Automatisches Kompilieren bei Änderungen
      vim.g.vimtex_compiler_latexmk = {
        continuous = 1,
      }

      -- Compiler sofort beim Öffnen starten
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*.tex",
        callback = function()
          vim.cmd("VimtexCompile")
        end,
      })
    end,
  },
}
