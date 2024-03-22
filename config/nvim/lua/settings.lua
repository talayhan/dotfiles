--Incremental live completion
vim.o.inccommand = 'nosplit'

--Set highlight on search
vim.o.hlsearch = true

--Make line numbers default
vim.wo.number = true

--Do not save when switching buffers
vim.o.hidden = true

--Enable mouse mode
vim.o.mouse = 'a'

--Enable break indent
vim.o.breakindent = true

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

--Set colorscheme (order is important here)
vim.o.termguicolors = true

--Save undo history
vim.cmd [[set undofile]]
vim.cmd [[set backup]]
vim.cmd [[set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp]]
vim.cmd [[set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp]]
vim.cmd [[set undodir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp]]

vim.cmd [[set ma]]

vim.cmd [[highlight ColorColumn ctermbg=lightgrey guibg=lightgrey]]

-- do not wrap searches at the end of the files
vim.o.wrapscan = false
-- start scrolling at 3rd row
vim.o.scrolloff = 3
--highlight tabs as >--, and trailing whitespace with -, spaw with .
vim.cmd [[set listchars=tab:>-,trail:-]]
vim.cmd [[set list]]
-- Y dis not work
vim.cmd [[highlight Highlighted ctermfg=231 ctermbg=24 cterm=NONE]]
vim.cmd [[highlight! link CursorLineNr Highlighted]]
-- Rg/PrettyPrintJSON
vim.cmd [[command! -nargs=* -complete=file Rg GrepperRg <args>]]
vim.api.nvim_create_user_command("PrettyPrintJSON", "%!python3 -m json.tool", {})

vim.o.history = 10000
vim.o.gdefault = true
vim.o.cinoptions = ':0,l1,t0,g0,(0'
vim.o.laststatus = 3

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.opt.compatible = false
vim.cmd [[ set nocompatible ]]
vim.cmd [[ filetype plugin on ]]
vim.cmd [[ syntax on ]]

--vim.o.t_Co = 256
vim.o.history = 10000
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.backspace = "indent,eol,start"
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 0
vim.o.smarttab = true
vim.o.expandtab = true
vim.o.list = true
vim.o.listchars = "tab:>-,trail:-"
vim.o.incsearch = true
vim.o.gdefault = true
vim.o.autoindent = true
vim.o.title = true
vim.o.ls = 2
vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"
vim.o.showmatch = true
vim.o.undofile = true
vim.o.lazyredraw = true
vim.o.ttyfast = true
vim.o.timeout = true
vim.o.timeoutlen = 1000
vim.o.ttimeout = true
vim.o.ttimeoutlen = 10
vim.o.diffopt = vim.o.diffopt .. ",iwhite"
vim.o.ofu = "syntaxcomplete#Complete"
vim.o.shortmess = vim.o.shortmess .. "c"
vim.opt.clipboard = "unnamedplus"

-- custom trigger for snippets
vim.g['UltiSnipsExpandTrigger'] = "<c-j>"
vim.g['UltiSnipsJumpForwardTrigger'] = "<c-b>"
vim.g['UltiSnipsJumpBackwardTrigger'] = "<c-z>"

-- multiplesearch config
vim.g['MultipleSearchMaxColors'] = 32
vim.g['MultipleSearchColorSequence'] = "DarkMagenta,DarkRed,LightYellow,cyan,gray,brown,LightBlue,green"
vim.g['MultipleSearchTextColorSequence'] = "black,black,black,black,black,black,black,black"

-- Abbreviations
-- no one is really happy until you have this shortcuts
vim.cmd([[
    cnoreabbrev W! w!
    cnoreabbrev w1 w!
    cnoreabbrev W1 w!
    cnoreabbrev Wa! wa!
    cnoreabbrev WA! wa!
    cnoreabbrev wa1 wa!
    cnoreabbrev Wa1 wa!
    cnoreabbrev wA1 wa!
    cnoreabbrev Wqa! wqa!
    cnoreabbrev Q! q!
    cnoreabbrev Qa! qa!
    cnoreabbrev qaa! qa!
    cnoreabbrev Qall! qall!
    cnoreabbrev Wq wq
    cnoreabbrev q1 q!
    cnoreabbrev Wa wa
    cnoreabbrev WA wa
    cnoreabbrev wA! wa!
    cnoreabbrev Wa! wa!
    cnoreabbrev wQ wq
    cnoreabbrev wQ! wq!
    cnoreabbrev WQ wq
    cnoreabbrev WQ! wq!
    cnoreabbrev Wqa wqa
    cnoreabbrev WQa wqa
    cnoreabbrev WQa! wqa!
    cnoreabbrev wqA! wqa!
    cnoreabbrev W w
    cnoreabbrev Q q
    cnoreabbrev Qall qall
]])

vim.cmd([[
au FileType vimwiki setlocal shiftwidth=4 tabstop=4 noexpandtab
au FileType markdown setlocal shiftwidth=4 tabstop=4 noexpandtab
au BufNewFile $VIMWIKI_DIARY_PATH/*.md :silent 0r !~/vimwiki/generate-vimwiki-diary-template.py '%'
]])
