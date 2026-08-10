vim.keymap.set("n", "<leader>ev", ":e ~/.config/nvim/init.lua<CR>")
vim.keymap.set("n", "<leader>cs", ":e ~/.config/nvim/README.md<CR>")
vim.keymap.set("n", "<leader>sv", ":source ~/.config/nvim/init.vim<CR>")

vim.keymap.set("n", "E", ":Ex<CR>")

vim.keymap.set("i", "jk", "<Esc>l")
vim.keymap.set("i", "kk", "<Esc>l")
vim.keymap.set("i", "jj", "<Esc>l")

-- misc
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<leader>n", "<cmd>noh<CR>")
vim.keymap.set("n", "<leader>;", "<cmd>set invnumber<CR>")
vim.keymap.set("n", "<leader>s", "<cmd>lua vim.lsp.buf.format({})<CR>")


-- search
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
local search_builtin = require 'telescope.builtin'
vim.keymap.set("n", "<c-f>", search_builtin.grep_string, { desc = "[S]earch current [W]ord (codebase)"  })
vim.keymap.set("n", "<leader><c-f>", search_builtin.live_grep, { desc = "[S]earch by [G]rep (codebase)" })


-- Copy
vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")

vim.keymap.set("n", "<leader><C-s>", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/g<Left><Left>")

-- surround
vim.keymap.set("n", "<leader>\"", "cs'")
vim.keymap.set("n", "<leader>'", "cs\"\'")

-- Buffers
function ChangeBuffer (forward)
  if forward then
    vim.api.nvim_command(":bn")
  else
    vim.api.nvim_command(":bp")
  end
end
vim.keymap.set("n", "<leader>f", "<cmd>lua ChangeBuffer(true)<CR>")
vim.keymap.set("n", "<leader>b", "<cmd>lua ChangeBuffer(false)<CR>")
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

-- searching
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>l', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<c-p>', builtin.git_files, { desc = 'Search [G]it files' })
vim.keymap.set('n', '<leader>p', builtin.find_files, { desc = 'Search [F]iles' })

-- package-scoped search: searches the whole repo, but floats matches from the
-- current file's package (nearest package.json above it) to the top and
-- down-sorts everything else
local sorters = require("telescope.sorters")
local BIG = 2 ^ 20 -- penalty large enough to dominate any fuzzy score

local function package_root()
  local start = vim.fn.expand("%:p:h")
  if start == "" then start = vim.fn.getcwd() end
  -- nearest package.json walking upward from the current file
  local found = vim.fs.find({ "package.json" }, { path = start, upward = true })[1]
  if found then return vim.fs.dirname(found) end
  return vim.fs.root(0, ".git") or vim.fn.getcwd()
end

-- wrap a base sorter so entries whose path starts with `prefix` keep their
-- score, and everything else gets pushed below by BIG (fuzzy order preserved
-- within each group)
local function package_first(base, prefix)
  local orig = base.scoring_function
  base.scoring_function = function(self, prompt, line, entry)
    local score = orig(self, prompt, line, entry)
    if score == -1 then return -1 end
    local path = (entry and (entry.filename or entry.value)) or line
    if prefix and path and vim.startswith(path, prefix) then
      return score
    end
    return score + BIG
  end
  return base
end

local function pkg_scoped(kind)
  local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
  local rel = vim.fs.relpath(root, package_root()) or ""
  local prefix = (rel ~= "" and rel ~= ".") and (rel .. "/") or nil
  if kind == "find" then
    search_builtin.find_files({
      cwd = root,
      sorter = package_first(sorters.get_fuzzy_file(), prefix),
    })
  elseif kind == "grep" then
    search_builtin.live_grep({
      cwd = root,
      sorter = package_first(sorters.highlighter_only({}), prefix),
    })
  else
    search_builtin.grep_string({
      cwd = root,
      sorter = package_first(sorters.get_fuzzy_file(), prefix),
    })
  end
end

vim.keymap.set("n", "<leader>P", function() pkg_scoped("find") end,
  { desc = "Find files (package-first)" })
vim.keymap.set("n", "<leader><leader>f", function() pkg_scoped("grep") end,
  { desc = "Live grep (package-first)" })
vim.keymap.set("n", "<leader><leader>w", function() pkg_scoped("word") end,
  { desc = "Search word (package-first)" })

-- Git
-- NOTE: line blame is gitsigns <leader>hb; toggle inline blame is <leader>tb
vim.keymap.set("n", "<leader><leader>g", "<cmd>GBrowse<CR>")

-- Terminal
-- vim.keymap.set("t", "<Esc>", "<C-\\><C-n>") CLASH WITH CHANGE TAB

-- project commands
local function runOnCurrentFile(util)
  local path = vim.fn.expand("%:p")
  local filename = vim.fn.expand("%:gs?/home/emcandrew/dev/\\w*/??")
  local type = vim.fn.expand("%:e")
  local cmd = "T echo 'No test runner found'"

  if type == "py" then
    if path:match("dev/cwa") then
      cmd = "T cwa; docker compose run --rm cwa " .. util .. " " .. filename
    elseif path:match("dev/cds") then
      cmd = "T cds; docker compose run --rm cds " .. util .. " " .. filename
    elseif path:match("dev/generative") then
      cmd = "T gas; make docker/build/test; docker run -it --rm --network gas-test-network gas:test pytest -vv " .. filename
    else
      cmd = "T cat " .. path
    end
  end
  if type == "js" or type == "ts" or type == "tsx" then
    if path:match("dev/cwa") then
      cmd = "T cd frontend; yarn test " .. filename
    else
      cmd = "T yarn test " .. filename
    end
  end

  vim.api.nvim_command(cmd)
  vim.api.nvim_command("Topen")
end
vim.keymap.set("n", "<leader><F2>", function() runOnCurrentFile("black") end)

-- run the unit-test command against the current file in a terminal split
-- change UNIT_TEST_CMD to swap out the test runner
local UNIT_TEST_CMD = "just unit-test"
local unit_test_buf = nil
local function runUnitTest()
  local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
  local abs = vim.fn.expand("%:p")
  local rel = vim.fs.relpath(root, abs) or abs
  -- wipe the previous test terminal so buffers don't pile up
  if unit_test_buf and vim.api.nvim_buf_is_valid(unit_test_buf) then
    vim.api.nvim_buf_delete(unit_test_buf, { force = true })
  end
  -- run from the project root so the relative path resolves
  vim.cmd("botright vsplit | terminal cd " .. vim.fn.shellescape(root)
    .. " && " .. UNIT_TEST_CMD .. " " .. vim.fn.shellescape(rel))
  unit_test_buf = vim.api.nvim_get_current_buf()
end
vim.keymap.set("n", "<F2>", runUnitTest, { desc = "unit-test current file" })

vim.api.nvim_create_user_command("Pdb", function()
    local input = 'import pdb; pdb.set_trace()'
    vim.api.nvim_input('o' .. input .. '<ESC>>>==')
  end
, {})

-- notes
--vim.api.nvim_command("autocmd BufWritePost *_*_*.md :!TODAY_DIR=~/dev/notes python ~/dev/notes/parse.py %")

--vim.api.nvim_create_user_command("LLM", function()
    --vim.api.nvim_command("vsplit term://llm chat")
  --end
--, {})
