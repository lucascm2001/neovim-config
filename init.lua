---- CORE OPTIONS ----

vim.cmd("let g:netrw_liststyle = 3")
local opt = vim.opt -- for conciseness

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 4 -- 4 spaces for tabs (prettier default)
opt.shiftwidth = 4 -- 4 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- appearance

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- set default terminal when writing :term to pwsh.exe
vim.o.shell = "pwsh.exe"
vim.o.shellcmdflag = "-nologo -noprofile -ExecutionPolicy RemoteSigned -command"
vim.o.shellxquote = ""

---- KEYMAPS ----

-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jj to exit insert mode
keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with jj" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

keymap.set("t", "<leader><ESC>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

---- LAZY VIM ----

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

---- MAJORITY OF PLUGINS ----

require("lazy").setup({
	spec = {
		{
			{ "nvim-lua/plenary.nvim" }, -- lua functions that many plugins use
			{ "christoomey/vim-tmux-navigator" }, -- tmux & split window navigation within neovim
			{ "catppuccin/nvim", name = "catppuccin", priority = 1000 }, -- catppuccin color theme :)
			{
				"nvim-tree/nvim-tree.lua",
				dependencies = "nvim-tree/nvim-web-devicons", -- File Explorer
				config = function()
					local nvimtree = require("nvim-tree")

					-- recommended settings from nvim-tree documentation
					vim.g.loaded_netrw = 1
					vim.g.loaded_netrwPlugin = 1
					nvimtree.setup({
						view = { width = 35, relativenumber = true },
						git = { enable = true, ignore = false, timeout = 1500 }, -- Shows gitignored files
					})
					-- set keymaps for nvim-tree
					keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
					keymap.set(
						"n",
						"<leader>ef",
						"<cmd>NvimTreeFindFileToggle<CR>",
						{ desc = "Toggle file explorer on current file" }
					) -- toggle file explorer on current file
					keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
					keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- Refresh file explorer
				end,
			},
			{
				"folke/todo-comments.nvim",
				dependencies = { "nvim-lua/plenary.nvim" },
				opts = {},
				config = function()
					local todo = require("todo-comments")
					todo.setup({
						keywords = {
							NOTE = { color = "#77DD77" },
							PERF = { color = "#B1A2CA" },
						},
					})
					keymap.set("n", "]t", todo.jump_next, { desc = "Next todo comment" })
					keymap.set("n", "[t", todo.jump_prev, { desc = "Previous todo comment" })
				end,
			},
			{
				"folke/which-key.nvim",
				event = "VeryLazy", -- Opens up which keymaps are available
				init = function()
					vim.o.timeout = true
					vim.o.timeoutlen = 500
				end,
				opts = {},
			},
			{
				"nvim-telescope/telescope.nvim",
				branch = "0.1.x",
				dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" }, -- fuzzy finder for file exploration
				config = function()
					local telescope = require("telescope")
					local actions = require("telescope.actions")

					telescope.setup({
						defaults = {
							path_display = { "smart" },
							mappings = {
								i = {
									["<C-k>"] = actions.move_selection_previous,
									["<C-j>"] = actions.move_selection_next,
								},
							},
						},
					})
					-- telescope.load_extension("fzf")
					keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
					keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
					keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
					keymap.set(
						"n",
						"<leader>fc",
						"<cmd>Telescope grep_string<cr>",
						{ desc = "Find string under cursor in cwd" }
					)
				end,
			},
			{
				"akinsho/bufferline.nvim",
				dependencies = { "nvim-tree/nvim-web-devicons" },
				version = "*",
				opts = { options = { mode = "tabs", separator_style = "slant" } },
			}, -- Makes the buffers at the top look nice
			{ "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} }, -- Makes the status line at the bottom look nice
			{
				"nvim-treesitter/nvim-treesitter",
				event = { "BufReadPre", "BufNewFile" },
				build = ":TSUpdate",
				dependencies = { "windwp/nvim-ts-autotag" },
				config = function()
					local treesitter = require("nvim-treesitter.configs")

					-- configure treesitter
					treesitter.setup({
						-- enable syntax highlighting
						highlight = { enable = true },
						-- enable indentation
						indent = { enable = true },
						-- enable autotagging
						autotag = { enable = true },

						-- ensure these language parsers are installed
						-- this causes issues..
						ensure_installed = {
							"json",
							"markdown",
							"bash",
							"lua",
							"vim",
							"gitignore",
							"c",
							"cmake",
							"cpp",
							"html",
							"powershell",
							"python",
							"toml",
							"rust",
						},
					})
				end,
			},
			{
				"lukas-reineke/indent-blankline.nvim",
				event = { "BufReadPre", "BufNewFile" },
				main = "ibl",
				opts = { indent = { char = "┊" } },
			}, -- helps with indents
			{
				"hrsh7th/nvim-cmp",
				event = "InsertEnter",
				dependencies = {
					"hrsh7th/cmp-buffer",
					"hrsh7th/cmp-path",
					{ "L3MON4D3/LuaSnip", version = "v2.*", build = "make install_jsregexp" },
					"saadparwaiz1/cmp_luasnip", -- for autocompletion
					"rafamadriz/friendly-snippets", -- useful snippets
					"onsails/lspkind.nvim", -- vs code like pictograms
				},
				config = function()
					local cmp = require("cmp")

					local luasnip = require("luasnip")

					local lspkind = require("lspkind")

					-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
					require("luasnip.loaders.from_vscode").lazy_load()

					cmp.setup({
						preselect = cmp.PreselectMode.None,
						completion = {
							completeopt = "menu,menuone,preview,noselect",
						},
						snippet = { -- configure how nvim-cmp interacts with snippet engine
							expand = function(args)
								luasnip.lsp_expand(args.body)
							end,
						},
						mapping = cmp.mapping.preset.insert({
							["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
							["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
							["<C-b>"] = cmp.mapping.scroll_docs(-4),
							["<C-f>"] = cmp.mapping.scroll_docs(4),
							["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
							["<C-e>"] = cmp.mapping.abort(), -- close completion window
							["<CR>"] = cmp.mapping.confirm({ select = false }),
						}),
						-- sources for autocompletion
						sources = cmp.config.sources({
							{ name = "nvim_lsp" },
							{ name = "luasnip" }, -- snippets
							{ name = "buffer" }, -- text within current buffer
							{ name = "path" }, -- file system paths
						}),

						-- configure lspkind for vs-code like pictograms in completion menu
						formatting = {
							format = lspkind.cmp_format({
								maxwidth = 50,
								ellipsis_char = "...",
							}),
						},
					})
				end,
			},
			{ "hrsh7th/cmp-nvim-lsp", lazy = false },
			{
				"windwp/nvim-autopairs",
				event = { "InsertEnter" },
				dependencies = { "hrsh7th/nvim-cmp" }, -- auto closing pairs
				config = function()
					-- import nvim-autopairs
					local autopairs = require("nvim-autopairs")

					-- configure autopairs
					autopairs.setup({
						check_ts = true, -- enable treesitter
					})
					local cmp_autopairs = require("nvim-autopairs.completion.cmp")
					local cmp = require("cmp")
					cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
				end,
			},
			{
				"gbprod/substitute.nvim",
				event = { "BufReadPre", "BufNewFile" }, -- substitution plugin
				config = function()
					local substitute = require("substitute")
					substitute.setup()

					vim.keymap.set("n", "s", substitute.operator, { desc = "Substitute with motion " })
					vim.keymap.set("n", "ss", substitute.line, { desc = "Substitute line" })
					vim.keymap.set("n", "S", substitute.eol, { desc = "Substitute until end of line" })
					vim.keymap.set("x", "s", substitute.visual, { desc = "Substitute in visual mode" })
				end,
			},
			{ "kylechui/nvim-surround", event = { "BufReadPre", "BufNewFile" }, version = "*", config = true }, -- Can use ys to surround text with opening and closing items
			{ "mason-org/mason.nvim", opts = {} }, -- Handles all LSP plugins
			{ -- Configures formatting for any language wanted
				"stevearc/conform.nvim",
				event = { "BufReadPre", "BufNewFile" },
				config = function()
					local conform = require("conform")

					conform.setup({
						formatters_by_ft = {
							json = { "prettier" },
							yaml = { "prettier" },
							markdown = { "prettier" },
							lua = { "stylua" },
							python = { "ruff_organize_imports", "ruff_format", "ruff_fix" },
							rust = { "rustfmt" },
							c = { "clang-format" },
							cpp = { "clang-format" },
						},
						format_on_save = {
							lsp_fallback = true,
							async = false,
							timeout_ms = 1000,
						},
					})

					vim.keymap.set({ "n", "v" }, "<leader>mp", function()
						conform.format({
							lsp_fallback = true,
							async = false,
							timeout_ms = 1000,
						})
					end, { desc = "Format file or range (in visual mode)" })
				end,
			},
			{
				"folke/trouble.nvim", -- Creates diagnostics for errors and warnings
				dependencies = { "nvim-tree/nvim-web-devicons" },
				opts = {
					focus = true,
				},
				cmd = "Trouble",
			},
			{
				"mfussenegger/nvim-lint",
				event = { "BufReadPre", "BufNewFile" },
				config = function()
					local lint = require("lint")

					lint.linters_by_ft = {
						python = { "ruff" },
					}

					local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

					vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
						group = lint_augroup,
						callback = function()
							lint.try_lint()
						end,
					})

					vim.keymap.set("n", "<leader>l", function()
						lint.try_lint()
					end, { desc = "Trigger linting for current file" })
				end,
			},
			{ "lewis6991/gitsigns.nvim", opt = {} },
			{
				"kdheepak/lazygit.nvim",
				lazy = true,
				cmd = {
					"LazyGit",
					"LazyGitConfig",
					"LazyGitCurrentFile",
					"LazyGitFilter",
					"LazyGitFilterCurrentFile",
				},
				-- optional for floating window border decoration
				dependencies = {
					"nvim-lua/plenary.nvim",
				},
				-- setting the keybinding for LazyGit with 'keys' is recommended in
				-- order to load the plugin when the command is run for the first time
				keys = {
					{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
				},
			},
		},
	},
	{ colorscheme = { "catppuccin" } },
	checker = { enabled = true },
})

---- Enables autocomplete for the LSP ----
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

-- Connect the capabilities
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()
---- LSP ----

-- Lua LSP
vim.lsp.config["luals"] = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".git", ".luacheckrc", ".stylua.toml", "stylua.toml" },
	settings = { Lua = { runtime = { version = "LuaJIT" }, diagnostics = { globals = { "vim" } } } },
	capabilities = capabilities,
}

-- Python LSP
vim.lsp.config["ruff"] = {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	root_markers = { ".git", "pyproject.toml" },
	capabilities = capabilities,
}

-- Helper function for Pyright LSP
local function set_python_path(path)
	local clients = vim.lsp.get_clients({
		bufnr = vim.api.nvim_get_current_buf(),
		name = "pyright",
	})
	for _, client in ipairs(clients) do
		if client.settings then
			client.settings.python = vim.tbl_deep_extend("force", client.settings.python, { pythonPath = path })
		else
			client.config.settings =
				vim.tbl_deep_extend("force", client.config.settings, { python = { pythonPath = path } })
		end
		client.notify("workspace/didChangeConfiguration", { settings = nil })
	end
end

vim.lsp.config["pyright"] = {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	capabilities = capabilities,
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
		".git",
	},
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly",
				typeCheckingMode = "strict",
			},
			venvPath = ".",
			venv = ".venv",
		},
	},
	on_attach = function(client, bufnr)
		-- Ruff already handles all import organization
		vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
			client:exec_cmd({
				command = "pyright.organizeimports",
				arguments = { vim.uri_from_bufnr(bufnr) },
			})
		end, {
			desc = "Organize Imports",
		})
		vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
			desc = "Reconfigure pyright with the provided python path",
			nargs = 1,
			complete = "file",
		})
		vim.api.nvim_buf_set_keymap(
			bufnr,
			"n",
			"gd",
			"<cmd>lua vim.lsp.buf.definition()<CR>",
			{ noremap = true, silent = true }
		)
	end,
}

-- Rust LSP
vim.lsp.config["rust-analyzer"] = {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { ".git", "Cargo.toml" },
	single_file_support = true,
	capabilities = capabilities,
}

-- C/C++ LSP
vim.lsp.config["clangd"] = {
	cmd = { "clangd", "--background-index" },
	filetypes = { "c", "cpp" },
	root_markers = { "compile_commands.json", "compile_flags.txt" },
	capabilities = capabilities,
	on_attach = function()
		vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
	end,
}

vim.lsp.enable({ "luals", "ruff", "pyright", "rust-analyzer", "clangd" })
vim.cmd([[colorscheme catppuccin]]) -- enables the catppuccin theme

---- Key mappings for LSPs ----
vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Show buffer diagnostics" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show line diagnostics " })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show diagnostics for what is under cursor" })

vim.cmd("set completeopt+=noselect") -- Stops autocomplete from filling in things for you

vim.diagnostic.config({ -- Allows the diagnostic issue to show up inline
	virtual_text = true,
})
