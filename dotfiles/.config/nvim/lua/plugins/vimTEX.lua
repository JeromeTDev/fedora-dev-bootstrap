return {
  {
    "lervag/vimtex",
    ft = { "tex" },
    init = function()
      -- =============================
      -- Vimtex-Grundeinstellungen
      -- =============================

      -- Zathura als PDF Viewer
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_view_general_viewer = "zathura"
      vim.g.vimtex_view_general_options = '-x "%{line}" %pdf'

      -- Latexmk als Compiler, automatisch kontinuierlich
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "", -- optional: eigener build-Ordner
        continuous = 1, -- Auto-Kompilierung
        executable = "latexmk", -- Standard latexmk
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1", -- wichtig für PDF-Sync
        },
      }

      -- =============================
      -- Auto-Compile beim Öffnen
      -- =============================
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*.tex",
        callback = function()
          if not vim.g.vimtex or not vim.g.vimtex.compiler or vim.g.vimtex.compiler.running == 0 then
            vim.cmd("VimtexCompile")
          end
        end,
      })
    end,
  },
}
