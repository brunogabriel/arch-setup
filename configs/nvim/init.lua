-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Enable line wrapping
vim.opt.wrap = true

-- Break lines at word boundaries instead of mid-word
vim.opt.linebreak = true

-- (Optional) Add a visual indicator at the start of wrapped lines
--vim.opt.showbreak = "↳ "
