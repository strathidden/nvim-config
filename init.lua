---@diagnostic disable: undefined-global

vim.opt.number = true
vim.opt.relativenumber = false
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
vim.opt.colorcolumn = "110"
vim.opt.updatetime = 50
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 999
vim.opt.virtualedit = "block"
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true

vim.opt.formatoptions:remove({ "c", "r", "o" })

local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
vim.opt.undodir = undodir

vim.filetype.add({
    extension = {
        vert = "glsl",
        frag = "glsl",
        comp = "glsl",
    },
})

vim.g.mapleader = " "

vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Move up" })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Move down" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Below split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Above split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Right split" })
vim.keymap.set("n", "<C-c>", "<C-w>c", { desc = "Close split" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

vim.keymap.set("x", "<leader>p", "\"_dP", { desc = "Paste without yanking" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left><Left>]], { desc = "Replace word" })

vim.keymap.set("n", "<leader>rc", function()
    vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Edit config" })

vim.keymap.set("n", "<leader>x", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format file" })

vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("last_loc", { clear = true }),
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
    desc = "Restore cursor position",
})

vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
        vim.cmd("wincmd =")
    end,
    desc = "Equalize splits",
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
    pattern = "*",
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
    desc = "Highlight yank",
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "marekh19/meowsoot.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("meowsoot")
        end,
    },
    {
        "echasnovski/mini.icons",
        lazy = true,
        opts = {},
        init = function()
            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        opts = {
            ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
            highlight = { enable = true },
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
                        ["ic"] = { query = "@class.inner", desc = "Select inner class" },
                        ["as"] = { query = "@scope", query_group = "locals", desc = "Select scope" },
                    },
                    selection_modes = {
                        ["@parameter.outer"] = "v",
                        ["@function.outer"] = "V",
                        ["@class.outer"] = "<c-v>",
                    },
                    include_surrounding_whitespace = true,
                },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "saghen/blink.cmp",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "clangd", "lua_ls" },
                automatic_installation = true,
            })

            vim.lsp.config("*", {
                capabilities = require("blink.cmp").get_lsp_capabilities(),
                on_attach = function(client, bufnr)
                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                    end
                    map("n", "gr", "<cmd>FzfLua lsp_references<CR>", "References")
                    map("n", "gD", vim.lsp.buf.declaration, "Declaration")
                    map("n", "gd", "<cmd>FzfLua lsp_definitions<CR>", "Definitions")
                    map("n", "gs", "<cmd>FzfLua lsp_definitions<CR>", "Definitions")
                    map("n", "gi", "<cmd>FzfLua lsp_implementations<CR>", "Implementations")
                    map("n", "gt", "<cmd>FzfLua lsp_type_definitions<CR>", "Type Definitions")
                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
                    map("n", "K", vim.lsp.buf.hover, "Hover")
                end,
            })

            vim.lsp.config("clangd", {
                cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed", "--cross-file-rename", "--header-insertion=never", "--pretty" },
            })

            vim.lsp.enable({ "clangd", "lua_ls" })

            vim.diagnostic.config({
                virtual_text = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "󰅚 ",
                        [vim.diagnostic.severity.WARN] = "󰀪 ",
                        [vim.diagnostic.severity.INFO] = "󰋽 ",
                        [vim.diagnostic.severity.HINT] = "󰌶 ",
                    },
                },
            })
        end,
    },
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets", "saghen/blink.compat" },
        version = "*",
        opts = {
            keymap = {
                preset = "default",
                ['<CR>'] = { 'accept', 'fallback' },
            },
            appearance = {
                nerd_font_variant = "mono",
            },
            completion = {
                menu = { auto_show = true },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            fuzzy = {
                implementation = "prefer_rust_with_warning",
            },
        },
        opts_extend = { "sources.default" },
    },
    {
        "echasnovski/mini.pairs",
        event = "InsertEnter",
        opts = {
            modes = { insert = true, command = true, terminal = false },
            skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
            skip_ts = { "string" },
            skip_unbalanced = true,
            markdown = true,
        },
    },
    {
        "echasnovski/mini.comment",
        event = "VeryLazy",
        dependencies = {
            {
                "JoosepAlviste/nvim-ts-context-commentstring",
                opts = { enable_autocmd = false },
            },
        },
        opts = {
            options = {
                custom_commentstring = function()
                    return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo
                        .commentstring
                end,
            },
        },
    },
    {
        "ibhagwan/fzf-lua",
        dependencies = { "echasnovski/mini.icons" },
        cmd = "FzfLua",
        opts = {
            fzf_colors = true,
            winopts = {
                preview = {
                    layout = "vertical",
                    vertical = "down:45%",
                },
            },
        },
        keys = {
            { "<leader>f", "<cmd>FzfLua files<cr>",     desc = "Find Files" },
            { "<leader>g", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
        },
    },
    {
        "stevearc/oil.nvim",
        dependencies = { "echasnovski/mini.icons" },
        config = function()
            require("oil").setup({
                default_file_explorer = true,
                delete_to_trash = true,
                columns = { "icon" },
                keymaps = {
                    ["<C-h>"] = false,
                    ["<C-j>"] = false,
                    ["<C-k>"] = false,
                    ["<C-l>"] = false,
                    ["<C-c>"] = false,
                },
                view_options = { show_hidden = true },
            })
        end,
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    },
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G" },
    },
    {
        "mbbill/undotree",
        keys = {
            { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undotree" },
        },
    },
    {
        "folke/trouble.nvim",
        opts = {},
        cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
        keys = {
            { "<leader>q", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
            {
                "[q",
                function()
                    if require("trouble").is_open() then
                        require("trouble").prev({ skip_groups = true, jump = true })
                    else
                        pcall(vim.cmd.cprev)
                    end
                end,
                desc = "Previous Trouble/Quickfix",
            },
            {
                "]q",
                function()
                    if require("trouble").is_open() then
                        require("trouble").next({ skip_groups = true, jump = true })
                    else
                        pcall(vim.cmd.cnext)
                    end
                end,
                desc = "Next Trouble/Quickfix",
            },
        },
    },
    {
        "folke/zen-mode.nvim",
        cmd = "ZenMode",
        opts = {},
        keys = {
            { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
        },
    },
    {
        "echasnovski/mini.statusline",
        version = false,
        opts = {},
    },
    {
        "echasnovski/mini.surround",
        version = false,
        opts = {},
    },
}, {
    install = { colorscheme = { "meowsoot" } },
})
