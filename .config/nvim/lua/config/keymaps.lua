-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

vim.keymap.set("n", "<leader>ev", ":e ~/.config/nvim/init.vim<CR>")
vim.keymap.set("n", "<leader>cs", ":e ~/.config/nvim/README.md<CR>")
vim.keymap.set("n", "<leader>sv", ":source ~/.config/nvim/init.vim<CR>")

vim.keymap.set("n", "E", ":Ex<CR>")

vim.keymap.set("i", "jk", "<Esc>l")
vim.keymap.set("i", "kk", "<Esc>l")
vim.keymap.set("i", "jj", "<Esc>l")

-- misc
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<leader>n", "<cmd>noh<CR>")
vim.keymap.set("n", "<leader>;", "<cmd>set invnumber<CR>")

-- Replace '<leader>mykey' with whatever binding you want to use
vim.keymap.set("n", "<C-p>", LazyVim.pick("files", { root = false }), {
  desc = "Find Files (cwd)",
})

-- Copy
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')

-- Buffers
function ChangeBuffer(forward)
  if forward then
    vim.api.nvim_command(":bn")
  else
    vim.api.nvim_command(":bp")
  end
end
vim.keymap.set("n", "<S-f>", "<cmd>BufferLineCycleNext<CR>")
vim.keymap.set("n", "<S-b>", "<cmd>BufferLineCyclePrev<CR>")
vim.keymap.set("n", "<leader>d", ":bp|bd #<CR>")
vim.keymap.set("n", "<leader>g", ":b#<CR>")
vim.keymap.set("n", "<leader>G", ":bm<CR>")
vim.keymap.set("n", "<leader>1", ":b1<CR>")
vim.keymap.set("n", "<leader>2", ":b2<CR>")
vim.keymap.set("n", "<leader>3", ":b3<CR>")
vim.keymap.set("n", "<leader>4", ":b4<CR>")
vim.keymap.set("n", "<leader>5", ":b5<CR>")
vim.keymap.set("n", "<leader>6", ":b6<CR>")
vim.keymap.set("n", "<leader>7", ":b7<CR>")
vim.keymap.set("n", "<leader>8", ":b8<CR>")
vim.keymap.set("n", "<leader>9", ":b9<CR>")
vim.keymap.set("n", "<leader>l", function()
  Snacks.picker.buffers()
end)
