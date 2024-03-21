--mostly copied from \@github/vzaa/vimconf
vim.g.mapleader = ','
vim.g.maplocalleader = ','

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    {
        "luisiacc/gruvbox-baby",
        lazy = false,
        priority = 1000,
        config = function()
            -- Example config in Lua
            vim.g.gruvbox_baby_function_style = "NONE"
            vim.g.gruvbox_baby_keyword_style = "italic"

            -- Enable telescope theme
            vim.g.gruvbox_baby_telescope_theme = 1

            -- Enable transparent mode
            vim.g.gruvbox_baby_transparent_mode = 1

            -- Load the colorscheme
            vim.cmd[[colorscheme gruvbox-baby]]
        end,
    },
    {
        "jackMort/ChatGPT.nvim",
        event = "VeryLazy",
        config = function()
            require("chatgpt").setup()
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "folke/trouble.nvim",
            "nvim-telescope/telescope.nvim"
        }
    },
    'tpope/vim-commentary',
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',
    'tpope/vim-sleuth',
    'tpope/vim-surround',
    'tpope/vim-dispatch',
    'tpope/vim-abolish',
    'talayhan/vim-snippets',
    --'ntpeters/vim-better-whitespace',

    'talayhan/s-vim',
    -- Life saver
    'airblade/vim-gitgutter',
    'tpope/vim-fugitive',
    {'junegunn/gv.vim', dependencies = { "tpope/vim-fugitive"} },
    'scrooloose/nerdtree',
    'scrooloose/nerdcommenter',
    'majutsushi/tagbar',

    -- Text Utils
    'easymotion/vim-easymotion',
    'vim-scripts/MultipleSearch',
    --{'suan/vim-instant-markdown', ft = { "markdown" } },
    'lervag/vimtex',
    'vimwiki/vimwiki',
    'weirongxu/plantuml-previewer.vim',
    'aklt/plantuml-syntax',
    'tyru/open-browser.vim',
    'conornewton/vim-latex-preview',

    -- General helper
    -- use 'wesQ3/vim-windowswap'  -- Commented due to not supported plugin format
    'will133/vim-dirdiff',

    -- Syntax checking
    --'sheerun/vim-polyglot',
    'vim-syntastic/syntastic',
    --'SirVer/ultisnips',

    -- Web
    'pangloss/vim-javascript',
    'maksimr/vim-jsbeautify',
    'mattn/emmet-vim',
    --'ap/vim-css-color',

    -- Programming Language Specific
    'rhysd/vim-clang-format',
    'fatih/vim-go',

    -- Utils
    'mhinz/vim-grepper',
    -- Use release branch (recommend)
    'rhysd/committia.vim',
    'chrisbra/vim-diff-enhanced',
    'vim-scripts/zoomwin',

    'nvim-lua/plenary.nvim',
    -- LRU
    'xolox/vim-misc',

    -- On test stage
    -- use 'vim-utils/vim-man'
    -- use 'tricktux/pomodoro.vim'

    'mbbill/undotree',
    'rust-lang/rust.vim',
    'leafo/moonscript-vim',
    'maxbrunsfeld/vim-yankstack',
    'vim-scripts/a.vim',
    { "sindrets/diffview.nvim",   dependencies = { "nvim-lua/plenary.nvim" } },
    { 'windwp/nvim-autopairs',    opts = {} },
    { 'kyazdani42/nvim-tree.lua', opts = {} },
    { 'lewis6991/gitsigns.nvim',  opts = {} },
    { "rcarriga/nvim-dap-ui",     dependencies = { "mfussenegger/nvim-dap" } },
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
    },

    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
        },
    },

    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-path',
            'andersevenrud/cmp-tmux'
        },
        opts = {
            sources = {
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'path' },
                { name = 'buffer' },
                {
                    name = 'tmux',
                    option = {
                        all_panes = true,
                    }
                }
            },
        }
    },

    {
        'nvim-lualine/lualine.nvim',
        opts = {
            options = {
                icons_enabled = false,
                theme = 'gruvbox',
                component_separators = '|',
                section_separators = '',
            },
        },
    },

    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-ui-select.nvim' }
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
            return vim.fn.executable 'make' == 1
        end,
    },

    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        config = function()
            pcall(require('nvim-treesitter.install').update { with_sync = true })
        end,
    },
    -- { import = 'custom.plugins' },
}, {})

require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')

-- Setup mason so it can manage external tooling
require('mason').setup()

require('settings')
require('lsp')
require('comp')
require('treesitter')
require('keymaps')

local dap = require('dap')

dap.adapters.codelldb = {
    type = 'server',
    port = '13000',
    executable = {
        command = 'codelldb',
        args = { '--port', '13000' },
    },
}

dap.configurations.c = {
    {
        type = "codelldb",
        request = "launch",
        cwd = '${workspaceFolder}',
        terminal = 'integrated',
        console = 'integratedTerminal',
        stopOnEntry = false,
        program = function()
            -- want it in cmdline, without callback. so fn.input better than ui.input
            return vim.fn.input('executable: ', vim.loop.cwd() .. '/', 'file')
        end
    }
}
dap.configurations.cpp = dap.configurations.c
dap.configurations.rust = dap.configurations.cpp
dap.configurations.zig = dap.configurations.cpp

require("dapui").setup()
