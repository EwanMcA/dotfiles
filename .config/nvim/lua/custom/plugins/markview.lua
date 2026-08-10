-- markview.nvim: an experimental markdown (and more) previewer/renderer for Neovim.
-- https://github.com/OXY2DEV/markview.nvim

vim.pack.add {
  'https://github.com/OXY2DEV/markview.nvim',
  -- Optional: icon support for the rendered output.
  'https://github.com/nvim-tree/nvim-web-devicons',
}

-- markview relies on the `markdown`, `markdown_inline`, `html`, `latex` and `yaml`
-- treesitter parsers. This config auto-installs parsers on demand (see the
-- treesitter FileType autocmd in init.lua), so opening a markdown file will
-- pull them in automatically.

require('markview').setup()
