-- ============================================================================
-- SHARED (both Neovim standalone and vscode-neovim)
-- ============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.mouse = "a"
vim.opt.clipboard:append("unnamedplus")
vim.opt.iskeyword:append("-")
vim.opt.selection = "inclusive"
vim.opt.backspace = "indent,eol,start"
vim.opt.hidden = true

vim.opt.timeoutlen = 5000
vim.opt.ttimeoutlen = 50
vim.opt.updatetime = 300

vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
})
-- ============================================================================
-- SHARED KEYMAPS
-- ============================================================================

-- better movement in wrapped text
vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

vim.keymap.set("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "show diagnostics under cursor" })

-- ============================================================================
-- SHARED AUTOCMDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then
			return
		end
		local last_pos = vim.api.nvim_buf_get_mark(0, '"')
		local last_line = vim.api.nvim_buf_line_count(0)
		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end
		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- ============================================================================
-- VSCODE: debug + REPL keymaps (vscode-neovim only)
-- ============================================================================
if vim.g.vscode then
	local vscode = require("vscode")

	-- Send to Python terminal (works for line or selection)
	vim.keymap.set("n", "<leader><CR>", function()
		vscode.action("python.execSelectionInTerminal")
	end, { desc = "Send line to Python terminal" })

	vim.keymap.set("v", "<leader><CR>", function()
		vscode.action("python.execSelectionInTerminal")
	end, { desc = "Send selection to Python terminal" })

	-- Debug (leader-b prefix)
	vim.keymap.set("n", "<leader>bb", function()
		vscode.action("editor.debug.action.toggleBreakpoint")
	end, { desc = "[B]reakpoint toggle" })

	vim.keymap.set("n", "<leader>bc", function()
		vscode.action("workbench.action.debug.continue")
	end, { desc = "[B]reakpoint [C]ontinue" })

	vim.keymap.set("n", "<leader>bi", function()
		vscode.action("workbench.action.debug.stepInto")
	end, { desc = "[B]reakpoint step [I]nto" })

	vim.keymap.set("n", "<leader>bo", function()
		vscode.action("workbench.action.debug.stepOver")
	end, { desc = "[B]reakpoint step [O]ver" })

	vim.keymap.set("n", "<leader>bO", function()
		vscode.action("workbench.action.debug.stepOut")
	end, { desc = "[B]reakpoint step [O]ut" })

	vim.keymap.set("n", "<leader>bq", function()
		vscode.action("workbench.action.debug.stop")
	end, { desc = "[B]reakpoint [Q]uit" })

	-- Focus debug console / editor
	vim.keymap.set("n", "<leader>bf", function()
		vscode.action("workbench.debug.action.focusRepl")
	end, { desc = "[B]reakpoint [F]ocus debug console" })

	vim.keymap.set("n", "<leader>be", function()
		vscode.action("workbench.action.focusActiveEditorGroup")
	end, { desc = "[B]reakpoint focus [E]ditor" })

  vim.keymap.set("n", "<leader>bs", function()
     vscode.action("workbench.action.debug.start")
  end, { desc = "[B]reakpoint [S]tart" })

  vim.keymap.set("n", "<leader>br", function()
     vscode.action("workbench.action.debug.restart")
  end, { desc = "[B]reakpoint [R]estart" })

  vim.keymap.set("n", "<leader>bC", function()
     vscode.action("editor.debug.action.conditionalBreakpoint")
  end, { desc = "[B]reakpoint [C]onditional" })

  vim.keymap.set("n", "<leader>bl", function()
     vscode.action("editor.debug.action.addLogPoint")
  end, { desc = "[B]reakpoint [L]ogpoint" })

  vim.keymap.set({ "n", "v" }, "<leader>bw", function()
     vscode.action("editor.debug.action.selectionToRepl")
  end, { desc = "[B]reakpoint send to console" })

	return
end

-- ============================================================================
-- STANDALONE OPTIONS  (Neovim only, not vscode-neovim)
-- ============================================================================

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.showmatch = true
vim.opt.cmdheight = 1
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.showmode = false
vim.opt.pumheight = 10
vim.opt.pumblend = 10
vim.opt.winblend = 0

local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = undodir

vim.opt.autoread = true
vim.opt.autowrite = false
vim.opt.errorbells = false
vim.opt.autochdir = false

vim.opt.path:append("**")
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.signcolumn = "yes:1"
vim.opt.numberwidth = 5

vim.opt.diffopt:append("linematch:60")

-- Folding: requires treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

-- ============================================================================
-- STANDALONE KEYMAPS
-- ============================================================================

vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- terminal bounce: Terminal → Editor
for _, key in ipairs({ "<D-o>", "<C-x>o" }) do
	vim.keymap.set("t", key, "<C-\\><C-n><C-w>w", { desc = "Bounce to other pane" })
end
-- terminal bounce: Editor → Terminal
for _, key in ipairs({ "<D-o>", "<C-x>o" }) do
	vim.keymap.set({ "n", "i" }, key, function()
		vim.cmd("wincmd p")
		if vim.bo.buftype == "terminal" then
			vim.cmd("startinsert")
		end
	end, { desc = "Bounce to other pane" })
end

-- ============================================================================
-- STANDALONE AUTOCMDS
-- ============================================================================

-- Format on save (lua + python only, requires efm)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then return end
		if not vim.bo[args.buf].modifiable then return end
		if vim.api.nvim_buf_get_name(args.buf) == "" then return end

		pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 2000,
		})
	end,
})

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- ============================================================================
-- PLUGINS (vim.pack)
-- ============================================================================

vim.pack.add({
	"https://www.github.com/lewis6991/gitsigns.nvim",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/creativenull/efmls-configs-nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/folke/which-key.nvim",
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/leoluz/nvim-dap-go",
  "https://github.com/rebelot/kanagawa.nvim",

})

-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

-- theme


require("kanagawa").setup({
  compile = false,
  transparent = false,
  theme = "wave",
})

vim.cmd.colorscheme("kanagawa-wave")



-- Telescope
local setup_telescope = function()
	local telescope = require("telescope")
	telescope.setup({
		defaults = {
			layout_strategy = "horizontal",
			sorting_strategy = "ascending",
		},
	})

	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
	vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
	vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
	vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[F]ind [S]elect Telescope" })
	vim.keymap.set({ "n", "v" }, "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
	vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
	vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
	vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
	vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = "[F]ind Recent Files ('.' for repeat)" })
	vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "[F]ind [C]ommands" })
	vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffers" })

	vim.keymap.set("n", "<leader>/", function()
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			previewer = false,
		}))
	end, { desc = "[/] Fuzzily search in current buffer" })
end
setup_telescope()

-- Which-Key
require("which-key").setup({})

-- Treesitter
require("nvim-treesitter").setup({
	ensure_installed = {
		"vim",
		"vimdoc",
		"lua",
		"python",
		"markdown",
		"bash",
		"json",
    "go",
	},
})
-- TODO: consider adding "r" parser for R syntax highlighting

-- Gitsigns
require("gitsigns").setup({
	signs = {
		add = { text = "\u{2590}" },
		change = { text = "\u{2590}" },
		delete = { text = "\u{2590}" },
		topdelete = { text = "\u{25e6}" },
		changedelete = { text = "\u{25cf}" },
		untracked = { text = "\u{25cb}" },
	},
	signcolumn = true,
	current_line_blame = false,
})

vim.keymap.set("n", "]h", function()
	require("gitsigns").nav_hunk("next")
end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function()
	require("gitsigns").nav_hunk("prev")
end, { desc = "Previous git hunk" })
vim.keymap.set("n", "<leader>hs", function()
	require("gitsigns").stage_hunk()
end, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", function()
	require("gitsigns").reset_hunk()
end, { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Blame line" })
vim.keymap.set("n", "<leader>hB", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle inline blame" })
vim.keymap.set("n", "<leader>hd", function()
	require("gitsigns").diffthis()
end, { desc = "Diff this" })

-- Mason
require("mason").setup({})

-- ============================================================================
-- LSP, LINTING, FORMATTING & COMPLETION
-- ============================================================================

-- Rounded borders for all floating windows
local orig = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  return orig(contents, syntax, opts, ...)
end

-- LSP on-attach: keybindings 
local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts)

	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	-- Multi-result: telescope pickers
	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>gr", builtin.lsp_references, opts)
	vim.keymap.set("n", "<leader>gi", builtin.lsp_implementations, opts)
	vim.keymap.set("n", "<leader>gs", builtin.lsp_document_symbols, opts)
	vim.keymap.set("n", "<leader>gW", builtin.lsp_dynamic_workspace_symbols, opts)
	vim.keymap.set("n", "<leader>gt", builtin.lsp_type_definitions, opts)

end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

-- Blink (completion)
require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<Tab>"] = { "accept", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<CR>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = { menu = { auto_show = true } },
	sources = { default = { "lsp", "path", "buffer", "snippets" } },
	snippets = {
		expand = function(snippet)
			require("luasnip").lsp_expand(snippet)
		end,
	},
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
})

-- Shared LSP capabilities
vim.lsp.config["*"] = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}

-- LSP server configs
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("r_language_server", {
	cmd = { "R", "--slave", "-e", "languageserver::run()" },
	filetypes = { "r", "rmd" },
   root_dir = function(fname, bufnr)
     local path = type(fname) == "string" and fname
       or vim.api.nvim_buf_get_name(fname)
     return vim.fs.root(path, { ".git", "DESCRIPTION" }) or vim.fs.dirname(path)
   end,
})

vim.lsp.config("gopls", {
   cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/gopls") },
   filetypes = { "go", "gomod", "gowork", "gotmpl" },
})

-- EFM (linters + formatters for lua and python)
local luacheck = require("efmls-configs.linters.luacheck")
local stylua = require("efmls-configs.formatters.stylua")
local black = require("efmls-configs.formatters.black")

vim.lsp.config("efm", {
  cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/efm-langserver") },
  filetypes = { "lua", "python" },
  init_options = { documentFormatting = true },
  settings = {
    languages = {
      lua = { luacheck, stylua },
      python = { black }, -- just formatting; pylsp handles diagnostics
    },
  },
})

vim.lsp.config("pylsp", {
  cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/pylsp") },
  filetypes = { "python" },
})

-- Enable all configured LSP servers
vim.lsp.enable({
	"lua_ls",
	"efm",
	"r_language_server",
  "gopls",
  "pylsp",
})




-- ============================================================================
-- DAP (Debug Adapter Protocol)
-- ============================================================================

local dap = require("dap")
local dap_go = require("dap-go")

dap_go.setup()

vim.keymap.set("n", "<leader>bb", dap.toggle_breakpoint,  { desc = "[B]reakpoint toggle" })
vim.keymap.set("n", "<leader>bc", dap.continue,           { desc = "[B]reakpoint [C]ontinue" })
vim.keymap.set("n", "<leader>bo", dap.step_over,          { desc = "[B]reakpoint step [O]ver" })
vim.keymap.set("n", "<leader>bi", dap.step_into,          { desc = "[B]reakpoint step [I]nto" })
vim.keymap.set("n", "<leader>bO", dap.step_out,           { desc = "[B]reakpoint step [O]ut" })
vim.keymap.set("n", "<leader>br", dap.restart,            { desc = "[B]reakpoint [R]estart" })
vim.keymap.set("n", "<leader>bq", dap.terminate,          { desc = "[B]reakpoint [Q]uit" })

-- Run tests (non-debug)
vim.keymap.set("n", "<leader>ta", ":term go test ./...<CR>",
   { desc = "[G]o [T]est all" })
vim.keymap.set("n", "<leader>tf", function()
   vim.cmd("term go test -run " .. vim.fn.expand("<cword>"))
end, { desc = "[G]o [T]est function under cursor" })

-- Debug tests (DAP)
vim.keymap.set("n", "<leader>bdt", dap_go.debug_test,
   { desc = "[B]reakpoint [D]ebug [T]est" })
vim.keymap.set("n", "<leader>bdl", dap_go.debug_last_test,
   { desc = "[B]reakpoint [D]ebug [L]ast test" })


local function send_line_to_tmux()
  local line = vim.api.nvim_get_current_line()

  vim.fn.system({ "tmux", "set-buffer", line })
  vim.fn.system({ "tmux", "paste-buffer", "-t", ":.+" })
  vim.fn.system({ "tmux", "send-keys", "-t", ":.+", "Enter" })
end

vim.keymap.set("n", "<leader>j", send_line_to_tmux)


