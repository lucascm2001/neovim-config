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

-- session options recommended by auto-session
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

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
if not vim.uv.fs_stat(lazypath) then
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
					-- require("nvim-tree").setup({
					--   filesystem_watchers = {
					--     ignore_dirs = {
					--       "target",
					--       ".git",
					--       "node_modules",
					--     },
					--   },
					-- })
					-- recommended settings from nvim-tree documentation
					vim.g.loaded_netrw = 1
					vim.g.loaded_netrwPlugin = 1
					nvimtree.setup({
						view = { width = 35, relativenumber = true },
						git = { enable = true, ignore = false, timeout = 1500 }, -- Shows gitignored files
						filesystem_watchers = {
							ignore_dirs = {
								"target",
							},
						},
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
				"nvim-telescope/telescope.nvim", -- fuzzy finder for file exploration
				version = "*",
				dependencies = {
					"nvim-lua/plenary.nvim",
					"nvim-tree/nvim-web-devicons",
					{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
					"sharkdp/fd",
				},
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
					telescope.load_extension("fzf")
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
				branch = "main",
				init = function()
					vim.api.nvim_create_autocmd("FileType", {
						callback = function()
							-- Enable treesitter highlighting and disable regex syntax
							pcall(vim.treesitter.start)
							-- Enable treesitter-based indentation
							vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
						end,
					})

					-- Make sure all the language grammars below are installed
					local ensure_installed = {
						"c",
						"cpp",
						"json",
						"latex",
						"lua",
						"markdown",
						"matlab",
						"python",
						"rust",
						"typst",
						"yaml",
					}
					local already_installed = require("nvim-treesitter.config").get_installed()
					local parsers_to_install = vim.iter(ensure_installed)
						:filter(function(parser)
							return not vim.tbl_contains(already_installed, parser)
						end)
						:totable()
					require("nvim-treesitter").install(parsers_to_install)
				end,
			},
			{
				"lukas-reineke/indent-blankline.nvim",
				event = { "BufReadPre", "BufNewFile" },
				main = "ibl",
				opts = { indent = { char = "┊" } },
			}, -- helps with indents
			{
				"saghen/blink.cmp",
				dependencies = { "rafamadriz/friendly-snippets" },
				version = "1.*",
				---@module 'blink.cmp'
				---@type blink.cmp.Config
				opts = {
					keymap = {
						preset = "enter",
						["<C-j>"] = { "select_next", "fallback_to_mappings" },
						["<C-k>"] = { "select_prev", "fallback_to_mappings" },
					},
					appearance = { nerd_font_variant = "mono" },
					completion = {
						documentation = { auto_show = true },
						-- list = { selection = { preselect = false } },
					},
					cmdline = {
						keymap = {
							["<Tab>"] = { "accept" },
							["<CR>"] = { "accept_and_enter", "fallback" },
						},
						-- (optionally) automatically show the menu
						completion = { menu = { auto_show = true } },
					},
					sources = {
						default = { "lsp", "path", "snippets", "buffer" },
						providers = {
							cmdline = {
								min_keyword_length = function(ctx)
									-- when typing a command, only show when the keyword is 3 characters or longer
									if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
										return 3
									end
									return 0
								end,
							},
						},
					},
					fuzzy = { implementation = "prefer_rust_with_warning" },
				},
				opts_extend = { "sources.default" },
			},
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
						formatters = {
							["clang-format"] = {
								command = "C:/Qt/Qt5.15.2/Tools/QtCreator/bin/clang/bin/clang-format.exe",
							},
						},
						formatters_by_ft = {
							json = { "prettier" },
							yaml = { "prettier" },
							markdown = { "prettier" },
							lua = { "stylua" },
							python = { "ruff_organize_imports", "ruff_format", "ruff_fix" },
							rust = { "rustfmt" },
							c = { "clang-format" },
							cpp = { "clang-format" },
							typst = { "typstyle" },
						},
						format_on_save = {
							lsp_format = "fallback",
							timeout_ms = 3000,
						},
					})

					vim.keymap.set({ "n", "v" }, "<leader>mp", function()
						conform.format({
							lsp_format = "fallback",
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
						json = { "jsonlint" },
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
			{ "lewis6991/gitsigns.nvim", opts = {} },
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
			{
				"chomosuke/typst-preview.nvim",
				lazy = false,
				version = "1.*",
				opts = {},
			},
			{
				"lervag/vimtex",
				lazy = false, -- we don't want to lazy load vimTeX
			},
			{
				"rmagatti/auto-session",
				lazy = false,

				--- enables autocompletes for opts
				opts = {
					suppressed_dirs = { "~/", "~/Documents/dev", "~/Downloads", "/" },
				},
			},
			{ -- Configuration for debuggers
				"mfussenegger/nvim-dap",
				event = "VeryLazy",
				dependencies = {
					"rcarriga/nvim-dap-ui",
					"nvim-neotest/nvim-nio",
					"jay-babu/mason-nvim-dap.nvim",
					"theHamsta/nvim-dap-virtual-text",
				},
				config = function()
					local mason_dap = require("mason-nvim-dap")
					local dap = require("dap")
					local ui = require("dapui")
					local dap_virtual_text = require("nvim-dap-virtual-text")

					-- Dap Virtual Text
					dap_virtual_text.setup()

					mason_dap.setup({
						ensure_installed = { "python" },
						automatic_installation = true,
						handlers = {
							function(config)
								-- all sources with no handler get passed here

								-- Keep original functionality
								require("mason-nvim-dap").default_setup(config)
							end,
							python = function(config)
								config.adapters = {
									type = "executable",
									command = vim.fn.exepath("python"),
									args = {
										"-m",
										"debugpy.adapter",
									},
								}
								require("mason-nvim-dap").default_setup(config) -- don't forget this!
							end,
						},
					})

					dap.configurations = {
						python = {
							{
								-- The first three options are required by nvim-dap
								type = "python", -- the type here established link to the adapter definition
								request = "launch",
								name = "Launch file",

								-- Options below are for debugpy
								program = "${file}",
								pythonPath = function()
									-- Launching application from virtual environment
									local cwd = vim.fn.getcwd()
									if vim.fn.executable(cwd .. "/.venv/Scripts/python") == 1 then
										return cwd .. "/.venv/Scripts/python"
									else
										return "C:/Program Files/Python313/python.exe"
									end
								end,
							},
						},
					}
					-- Dap UI

					ui.setup()

					-- vim.fn.sign_define("DapBreakpoint", { text = "🐞" })

					dap.listeners.before.attach.dapui_config = function()
						ui.open()
					end
					dap.listeners.before.launch.dapui_config = function()
						ui.open()
					end
					dap.listeners.before.event_terminated.dapui_config = function()
						ui.close()
					end
					dap.listeners.before.event_exited.dapui_config = function()
						ui.close()
					end
					-- Debugger keymaps
					-- keymap.set("n", "<leader>b", { group = "Debugger", nowait = true, remap = false })
					keymap.set(
						"n",
						"<leader>bt",
						dap.toggle_breakpoint,
						{ nowait = true, remap = false, desc = "Toggle breakpoint" }
					)
					keymap.set("n", "<leader>bc", dap.continue, { nowait = true, remap = false, desc = "Continue" })
					keymap.set("n", "<leader>bi", dap.step_into, { nowait = true, remap = false, desc = "Step into" })
					keymap.set("n", "<leader>bo", dap.step_over, { nowait = true, remap = false, desc = "Step over" })
					keymap.set("n", "<leader>bu", dap.step_out, { nowait = true, remap = false, desc = "Step out" })
					keymap.set("n", "<leader>bq", function()
						dap.terminate()
						ui.close()
						dap_virtual_text.toggle()
					end, { nowait = true, remap = false, desc = "Terminate" })
				end,
			},
		},
	},
	{ colorscheme = { "catppuccin" } },
	checker = { enabled = true },
})

---- LSP ----

-- Lua LSP
vim.lsp.config["luals"] = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".git", ".luacheckrc", ".stylua.toml", "stylua.toml" },
	settings = { Lua = { runtime = { version = "LuaJIT" }, diagnostics = { globals = { "vim" } } } },
}

-- Python LSP
-- vim.lsp.config["ruff"] = {
-- 	cmd = { "ruff", "server" },
-- 	filetypes = { "python" },
-- 	root_markers = { ".git", "pyproject.toml" },
-- }

vim.lsp.config["ty"] = {
	cmd = { "ty", "server" },
	filetypes = { "python" },
	root_markers = { "ty.toml", "pyproject.toml", ".git" },
	on_attach = function(_, bufnr)
		vim.api.nvim_buf_set_keymap(
			bufnr,
			"n",
			"gd",
			"<cmd>lua vim.lsp.buf.definition()<CR>",
			{ noremap = true, silent = true }
		)
	end,
}

-- Helper function for Pyright LSP
-- local function set_python_path(path)
-- 	local clients = vim.lsp.get_clients({
-- 		bufnr = vim.api.nvim_get_current_buf(),
-- 		name = "pyright",
-- 	})
-- 	for _, client in ipairs(clients) do
-- 		if client.settings then
-- 			client.settings.python = vim.tbl_deep_extend("force", client.settings.python, { pythonPath = path })
-- 		else
-- 			client.config.settings =
-- 				vim.tbl_deep_extend("force", client.config.settings, { python = { pythonPath = path } })
-- 		end
-- 		client.notify("workspace/didChangeConfiguration", { settings = nil })
-- 	end
-- end

-- vim.lsp.config["pyright"] = {
-- 	cmd = { "pyright-langserver", "--stdio" },
-- 	filetypes = { "python" },
-- 	root_markers = {
-- 		"pyproject.toml",
-- 		"setup.py",
-- 		"setup.cfg",
-- 		"requirements.txt",
-- 		"Pipfile",
-- 		"pyrightconfig.json",
-- 		".git",
-- 	},
-- 	settings = {
-- 		python = {
-- 			analysis = {
-- 				autoSearchPaths = true,
-- 				useLibraryCodeForTypes = true,
-- 				diagnosticMode = "openFilesOnly",
-- 				typeCheckingMode = "strict",
-- 			},
-- 			venvPath = ".",
-- 			venv = ".venv",
-- 		},
-- 	},
-- 	on_attach = function(client, bufnr)
-- 		-- Ruff already handles all import organization
-- 		vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
-- 			client:exec_cmd({
-- 				command = "pyright.organizeimports",
-- 				arguments = { vim.uri_from_bufnr(bufnr) },
-- 			})
-- 		end, {
-- 			desc = "Organize Imports",
-- 		})
-- 		vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
-- 			desc = "Reconfigure pyright with the provided python path",
-- 			nargs = 1,
-- 			complete = "file",
-- 		})
-- 		vim.api.nvim_buf_set_keymap(
-- 			bufnr,
-- 			"n",
-- 			"gd",
-- 			"<cmd>lua vim.lsp.buf.definition()<CR>",
-- 			{ noremap = true, silent = true }
-- 		)
-- 	end,
-- }

-- Rust LSP
vim.lsp.config["rust-analyzer"] = {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { ".git", "Cargo.toml" },
	single_file_support = true,
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
			},
		},
	},
	on_attach = function(_, bufnr)
		vim.keymap.set(
			"n",
			"gd",
			vim.lsp.buf.definition,
			{ buffer = bufnr, noremap = true, silent = true, desc = "Go to definition" }
		)
	end,
}

-- C/C++ LSP
vim.lsp.config["clangd"] = {
	cmd = { "clangd", "--background-index" },
	filetypes = { "c", "cpp" },
	root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
	on_attach = function()
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true, desc = "Go to definition" })
	end,
}

-- Typst LSP
vim.lsp.config["tinymist"] = {
	cmd = { "tinymist" },
	filetypes = { "typst" },
	root_markers = { "main.typ", ".git" },
	on_attach = function(_, bufnr)
		vim.keymap.set(
			"n",
			"gd",
			vim.lsp.buf.definition,
			{ buffer = bufnr, noremap = true, silent = true, desc = "Go to definition" }
		)
	end,
}

vim.lsp.enable({ "luals", "ruff", "ty", "rust-analyzer", "clangd", "tinymist" })
vim.cmd([[colorscheme catppuccin]]) -- enables the catppuccin theme

---- Key mappings for LSPs ----
vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Show buffer diagnostics" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show line diagnostics " })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show diagnostics for what is under cursor" })

vim.cmd("set completeopt+=noselect") -- Stops autocomplete from filling in things for you

vim.diagnostic.config({ -- Allows the diagnostic issue to show up inline
	virtual_text = true,
})
