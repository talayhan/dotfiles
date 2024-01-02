-- This file can be loaded by calling `require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
    -- Packer can manage itself
    use {'wbthomason/packer.nvim', opt = true}

    -- Playground
    use 'talayhan/s-vim'

    -- Life saver
    use 'airblade/vim-gitgutter'
    use 'tpope/vim-fugitive'
    use {'junegunn/gv.vim', requires = 'tpope/vim-fugitive'}
    use 'scrooloose/nerdtree'
    use 'scrooloose/nerdcommenter'
    -- use 'xolox/vim-easytags'  -- Commented due to not supported plugin format
    use 'majutsushi/tagbar'
    use 'tpope/vim-dispatch'
    use 'sindrets/diffview.nvim'

    -- Cosmetics
    use 'sainnhe/gruvbox-material'
    use 'morhetz/gruvbox'
    use 'itchyny/lightline.vim'

    -- Text Utils
    use 'easymotion/vim-easymotion'
    use 'vim-scripts/MultipleSearch'
    use {'suan/vim-instant-markdown', ft = 'markdown'}
    use 'lervag/vimtex'
    use 'vimwiki/vimwiki'
    use 'tpope/vim-abolish'

    use 'weirongxu/plantuml-previewer.vim'
    use 'aklt/plantuml-syntax'
    use 'tyru/open-browser.vim'
    use 'conornewton/vim-latex-preview'

    -- General helper
    -- use 'wesQ3/vim-windowswap'  -- Commented due to not supported plugin format
    use 'will133/vim-dirdiff'

    -- Syntax checking
    use 'sheerun/vim-polyglot'
    use 'vim-syntastic/syntastic'
    use 'SirVer/ultisnips'
    use 'talayhan/vim-snippets'
    use 'godlygeek/tabular'
    use 'Raimondi/delimitMate'
    use 'wellle/tmux-complete.vim'
    use 'tpope/vim-surround'
    use 'ntpeters/vim-better-whitespace'

    -- Web
    use 'pangloss/vim-javascript'
    use 'maksimr/vim-jsbeautify'
    use 'mattn/emmet-vim'
    use 'ap/vim-css-color'

    -- Programming Language Specific
    use 'rhysd/vim-clang-format'
    use 'fatih/vim-go'

    -- Utils
    use 'mhinz/vim-grepper'
    -- Use release branch (recommend)
    use {'neoclide/coc.nvim', branch = 'release'}
    use 'rhysd/committia.vim'
    use 'chrisbra/vim-diff-enhanced'
    use 'vim-scripts/zoomwin'

    use 'nvim-lua/plenary.nvim'
    use {'nvim-telescope/telescope.nvim', tag = '0.1.2'}
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

    -- LRU
    use 'xolox/vim-misc'
    use 'vim-scripts/a.vim'

    -- On test stage
    -- use 'vim-utils/vim-man'
    -- use 'tricktux/pomodoro.vim'
    use 'ryanoasis/vim-devicons'
end)

