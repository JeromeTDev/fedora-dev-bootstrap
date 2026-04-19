local M = {}

-- Detect python executable
local python = vim.fn.executable("python") == 1 and "python" or vim.fn.executable("python3") == 1 and "python3" or nil
if not python then
  vim.notify("No Python executable found!", vim.log.levels.ERROR)
  return
end

-- Map filetypes to run commands
M.commands = {
  python = function(file)
    return python .. " " .. file
  end,

  lua = function(file)
    return "lua " .. file
  end,

  javascript = function(file)
    return "node " .. file
  end,

  typescript = function(file)
    return "ts-node " .. file
  end,

  sh = function(file)
    return "bash " .. file
  end,

  zsh = function(file)
    return "zsh " .. file
  end,

  c = function(file, file_no_ext)
    return "bash -c 'gcc " .. file .. " -o " .. file_no_ext .. " && ./" .. file_no_ext .. "'"
  end,

  cpp = function(file, file_no_ext)
    return "bash -c 'g++ " .. file .. " -o " .. file_no_ext .. " && ./" .. file_no_ext .. "'"
  end,

  rust = function()
    return "cargo run"
  end,

  go = function()
    return "go run ."
  end,

  java = function(file, file_no_ext)
    return "bash -c 'javac " .. file .. " && java " .. file_no_ext .. "'"
  end,

  cs = function(file, file_no_ext)
    return "bash -c 'csc " .. file .. " && mono " .. file_no_ext .. ".exe'"
  end,

  php = function(file)
    return "php " .. file
  end,

  ruby = function(file)
    return "ruby " .. file
  end,

  perl = function(file)
    return "perl " .. file
  end,

  r = function(file)
    return "Rscript " .. file
  end,
}

function M.run_file()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%")
  local file_no_ext = vim.fn.expand("%:r")

  local cmd_builder = M.commands[ft]

  if not cmd_builder then
    vim.notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  local cmd = cmd_builder(file, file_no_ext)

  -- Use ToggleTerm if available for better terminal experience
  local ok, toggleterm = pcall(require, "toggleterm")
  if ok then
    -- Execute command in a new toggle terminal
    local Terminal = require("toggleterm.terminal").Terminal
    local terminal = Terminal:new({
      cmd = cmd,
      direction = "horizontal",
      size = 15,
      close_on_exit = false,
    })
    terminal:toggle()
  else
    -- Fallback to regular terminal in horizontal split
    vim.cmd("belowright split | terminal " .. cmd)
  end
end

vim.keymap.set("n", "<leader>r", M.run_file, { desc = "▶ Run file", silent = true })

return M
