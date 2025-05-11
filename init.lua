vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.signcolumn = "no"

vim.opt.updatetime = 50

vim.opt.clipboard = "unnamedplus"

vim.opt.scrolloff = 999

vim.opt.virtualedit = "block"

vim.opt.inccommand = "split"

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

vim.g.mapleader = " "

-- glsl lsp fix
vim.filetype.add({
    extension = {
        vert = "glsl",
        frag = "glsl",
        comp = "glsl"
    },
})

-- line wrap fix
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', '<leader>q', vim.diagnostic.setqflist)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", "\"_dP")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left><Left>]])

vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")

vim.api.nvim_create_autocmd('BufReadPost', {
    group = vim.api.nvim_create_augroup('last_loc', { clear = true }),
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        'RRethy/base16-nvim',
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("base16-gruvbox-material-dark-soft")
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

				auto_install = true,

				highlight = {
					enable = true,
				},

				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<leader>ss",
						node_incremental = "<leader>si",
						scope_incremental = "<leader>sc",
						node_decremental = "<leader>sd",
					},
				},
				textobjects = {
					select = {
						enable = true,

						lookahead = true,

						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
							["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
						},
						selection_modes = {
							["@parameter.outer"] = "v", -- charwise
							["@function.outer"] = "V", -- linewise
							["@class.outer"] = "<c-v>", -- blockwise
						},
						include_surrounding_whitespace = true,
					},
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- import lspconfig plugin
			local lspconfig = require("lspconfig")

			-- import mason_lspconfig plugin
			local mason_lspconfig = require("mason-lspconfig")

			-- import cmp-nvim-lsp plugin
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			local opts = { noremap = true, silent = true }
			local on_attach = function(client, bufnr)
				opts.buffer = bufnr

				-- set keybinds
				opts.desc = "Show LSP references"
				vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show documentation for what is under cursor"
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor
			end

			-- used to enable autocompletion (assign to every lsp server config)
			local capabilities = cmp_nvim_lsp.default_capabilities()

			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			mason_lspconfig.setup({
                automatic_enable = {
                    exclude = {
                        "clangd",
                    },
                },
                capabilities = capabilities,
                on_attach = on_attach,
			})
            lspconfig.clangd.setup({
                cmd = { "clangd", "--header-insertion=never" },
                filetypes = { 'cpp', 'h', 'c', 'hpp' },
                capabilities = capabilities,
                on_attach = on_attach,
            })
		end,
	},
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			-- import mason
			local mason = require("mason")

			-- enable mason and configure icons
			mason.setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"onsails/lspkind.nvim",
		},
		config = function()
			local cmp = require("cmp")

			local lspkind = require("lspkind")

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,preview,noselect",
				},
				mapping = cmp.mapping.preset.insert({
					--["<S-Tab>"] = cmp.mapping.select_prev_item(), -- previous suggestion
					--["<Tab>"] = cmp.mapping.select_next_item(), -- next suggestion
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
					--["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<CR>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
                            cmp.confirm({
                                select = true,
                            })
						else
							fallback()
						end
					end),

					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "buffer" }, -- text within current buffer
					{ name = "path" }, -- file system paths
				}),
				formatting = {
					format = lspkind.cmp_format({
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
			})
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = { "InsertEnter" },
		dependencies = {
			"hrsh7th/nvim-cmp",
		},
		config = function()
			-- import nvim-autopairs
			local autopairs = require("nvim-autopairs")

			-- configure autopairs
			autopairs.setup({
				check_ts = true, -- enable treesitter
				ts_config = {
					lua = { "string" }, -- don't add pairs in lua string treesitter nodes
					javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
					java = false, -- don't check treesitter on java
				},
			})

			-- import nvim-autopairs completion functionality
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")

			-- import nvim-cmp plugin (completions plugin)
			local cmp = require("cmp")

			-- make autopairs and completion work together
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					path_display = { "smart" },
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous, -- move to prev result
							["<C-j>"] = actions.move_selection_next, -- move to next result
						},
                        n = { ['q'] = actions.close },
					},
                    extensions = {
                        fzf = {
                            fuzzy = true,
                            override_generic_sorter = true,
                            override_file_sorter = true,
                            case_mode = 'smart_case',
                        }
                    },
				},
			})

			telescope.load_extension("fzf")

			vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<cr>")
			vim.keymap.set("n", "<leader>g", "<cmd>Telescope live_grep<cr>")
		end,
	},
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup({
                delete_to_trash = true,
				columns = { "icon" },
				view_options = {
					show_hidden = true,
				},
			})
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
		end,
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")

			harpoon:setup()

			vim.keymap.set("n", "<leader>m", function()
				harpoon:list():add()
			end)
			vim.keymap.set("n", "<leader>e", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end)

			vim.keymap.set("n", "<leader>h", function()
				harpoon:list():select(1)
			end)
			vim.keymap.set("n", "<leader>j", function()
				harpoon:list():select(2)
			end)
			vim.keymap.set("n", "<leader>k", function()
				harpoon:list():select(3)
			end)
			vim.keymap.set("n", "<leader>l", function()
				harpoon:list():select(4)
			end)
		end,
	},
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },
    {
        "tpope/vim-fugitive",
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons'},
        config = function()
            local colors = {
                bg       = '#08080800',
                fg       = '#bbc2cf',
                yellow   = '#ECBE7B',
                cyan     = '#008080',
                darkblue = '#081633',
                green    = '#98be65',
                orange   = '#FF8800',
                violet   = '#a9a1e1',
                blue     = '#51afef',
                red      = '#ec5f67',
            }
            local conditions = {
                buffer_not_empty = function()
                    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
                end,
                hide_in_width = function()
                    return vim.fn.winwidth(0) > 80
                end,
                check_git_workspace = function()
                    local filepath = vim.fn.expand('%:p:h')
                    local gitdir = vim.fn.finddir('.git', filepath .. ';')
                    return gitdir and #gitdir > 0 and #gitdir < #filepath
                end,
            }
            local config = {
                options = {
                    globalstatus = true,
                    component_separators = '',
                    section_separators = '',
                    theme = {
                        normal = { c = { fg = colors.fg, bg = colors.bg } },
                        inactive = { c = { fg = colors.fg, bg = colors.bg } },
                    },
                },
                sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_y = {},
                    lualine_z = {},

                    lualine_c = {},
                    lualine_x = {},
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_y = {},
                    lualine_z = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_h = {},
                },
            }

            local function ins_left(component)
                table.insert(config.sections.lualine_c, component)
            end

            local function ins_right(component)
                table.insert(config.sections.lualine_x, component)
            end


            ins_left {
                'filename',
                path = 1,
                cond = conditions.buffer_not_empty,
                color = { fg = colors.violet, gui = 'bold' },
            }

            ins_left {
                'location',
                padding = { left = 0, right = 0 },
                color = { fg = colors.blue, gui = 'bold' },
            }
            ins_left {
                'branch',
                icon = "",
                color = { fg = colors.violet, gui = 'bold' },
                padding = { left = 0, right = 0 },
            }

            ins_left {
                'diff',
                symbols = { added = 'a', modified = 'm', removed = 'r' },
                diff_color = {
                    added = { fg = colors.green },
                    modified = { fg = colors.orange },
                    removed = { fg = colors.red },
                },
            }


            ins_left {
                'diagnostics',
                sources = { 'nvim_diagnostic' },
                symbols = { error = 'e', warn = 'w', info = 'i', hint = 'h' },
                diagnostics_color = {
                    color_error = { fg = colors.red },
                    color_warn = { fg = colors.yellow },
                    color_info = { fg = colors.cyan },
                    color_hint = { fg = colors.cyan },
                },
            }

            ins_left {
                function()
                    local msg = 'NoLsp'
                    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
                    local clients = vim.lsp.get_clients()
                    if next(clients) == nil then
                        return msg
                    end
                    for _, client in ipairs(clients) do
                        local filetypes = client.config.filetypes
                        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                            return client.name
                        end
                    end
                    return msg
                end,
                color = { fg = colors.violet, gui = 'bold' },
                cond = conditions.hide_in_width,
            }

            ins_left {
                'o:encoding',
                fmt = string.upper,
                color = { fg = colors.green, gui = 'bold' },
                cond = conditions.hide_in_width,
            }

            ins_left {
                'fileformat',
                fmt = string.upper,
                icons_enabled = false,
                color = { fg = colors.green, gui = 'bold' },
                cond = conditions.hide_in_width,
            }

            ins_right {
                'datetime',
                color = { fg = colors.violet, gui = 'bold' },
            }

            require("lualine").setup(config)
        end
    },
    {
        "laytan/cloak.nvim",
        config = function()
            require("cloak").setup({})
        end
    },
    {
        "kawre/leetcode.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            -- "ibhagwan/fzf-lua",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
        opts = {
            ---@type string
            arg = "leetcode.nvim",

            ---@type lc.lang
            lang = "cpp",

            cn = { -- leetcode.cn
                enabled = false, ---@type boolean
                translator = true, ---@type boolean
                translate_problems = true, ---@type boolean
            },

            ---@type lc.storage
            storage = {
                home = vim.fn.stdpath("data") .. "/leetcode",
                cache = vim.fn.stdpath("cache") .. "/leetcode",
            },

            ---@type table<string, boolean>
            plugins = {
                non_standalone = false,
            },

            ---@type boolean
            logging = true,

            injector = {}, ---@type table<lc.lang, lc.inject>

            cache = {
                update_interval = 60 * 60 * 24 * 7, ---@type integer 7 days
            },

            console = {
                open_on_runcode = true, ---@type boolean

                dir = "row", ---@type lc.direction

                size = { ---@type lc.size
                    width = "90%",
                    height = "75%",
                },

                result = {
                    size = "60%", ---@type lc.size
                },

                testcase = {
                    virt_text = true, ---@type boolean

                    size = "40%", ---@type lc.size
                },
            },

            description = {
                position = "left", ---@type lc.position

                width = "40%", ---@type lc.size

                show_stats = true, ---@type boolean
            },

            ---@type lc.picker
            picker = { provider = nil },

            hooks = {
                ---@type fun()[]
                ["enter"] = {},

                ---@type fun(question: lc.ui.Question)[]
                ["question_enter"] = {},

                ---@type fun()[]
                ["leave"] = {},
            },

            keys = {
                toggle = { "q" }, ---@type string|string[]
                confirm = { "<CR>" }, ---@type string|string[]

                reset_testcases = "r", ---@type string
                use_testcase = "U", ---@type string
                focus_testcases = "H", ---@type string
                focus_result = "L", ---@type string
            },

            ---@type lc.highlights
            theme = {},

            ---@type boolean
            image_support = false,
        }
    }
})
