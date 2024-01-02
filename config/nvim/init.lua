require("plugins")

-- Set options
--
vim.g.mapleader = ','

-- vim.o.nocompatible = true
vim.o.termguicolors = true
vim.o.t_Co = 256
vim.o.history = 10000
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.mouse = "a"
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.backspace = "indent,eol,start"
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 0
vim.o.smarttab = true
vim.o.expandtab = true
vim.o.list = true
vim.o.listchars = "tab:>-,trail:-"
vim.o.hidden = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.gdefault = true
vim.o.number = true
vim.o.autoindent = true
vim.o.title = true
vim.o.ls = 2
vim.o.scrolloff = 3
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
vim.wo.signcolumn = "yes"
vim.o.shortmess = vim.o.shortmess .. "c"
vim.opt.clipboard = "unnamedplus"

-- Setting colorscheme and background
vim.cmd('colorscheme gruvbox')
vim.opt.background = 'dark'

-- Set status line
vim.cmd [[autocmd FileType typescript,javascript set expandtab]]
vim.cmd [[autocmd FileType markdown,md set tabstop=4 shiftwidth=4 expandtab | %retab!]]

-- Center after certain movements
vim.api.nvim_set_keymap('n', '*', '*zz', {})
vim.api.nvim_set_keymap('n', '#', '#zz', {})
vim.api.nvim_set_keymap('n', 'n', 'nzz', {})
vim.api.nvim_set_keymap('n', 'N', 'Nzz', {})
vim.api.nvim_set_keymap('n', ']]', ']]zz', {})
vim.api.nvim_set_keymap('n', '[[', '[[zz', {})
vim.api.nvim_set_keymap('n', '{{', '{{zz', {})
vim.api.nvim_set_keymap('n', '}}', '}}zz', {})

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

-- Key mappings (nnoremap)
vim.api.nvim_set_keymap('n', 'q<space>', ':close<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader><space>', ':noh<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>r', ':Grepper -tool git -open -switch -cword -noprompt<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>D', ':vert scs find 1 <C-R>=expand("<cword>")<CR><CR>z<CR> :cope<CR><CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>V', ':vert scs find 3 <C-R>=expand("<cword>")<CR><CR>z<CR> :cope<CR><CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>N', ':GrepperRg -tc <C-R>=expand("<cword>")<CR><CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F1>', '<ESC>', {})
vim.api.nvim_set_keymap('n', '<space>', '<C-^>', {})
vim.api.nvim_set_keymap('n', '<c-h>', '<C-w>h', {})
vim.api.nvim_set_keymap('n', '<c-j>', '<C-w>j', {})
vim.api.nvim_set_keymap('n', '<c-k>', '<C-w>k', {})
vim.api.nvim_set_keymap('n', '<c-l>', '<C-w>l', {})
vim.api.nvim_set_keymap('n', '<leader>P', ':exe "Search " . expand("<cword>")<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent> <Leader>ml', ':call AppendModeline()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent> <C-w>z', ':ZoomWin<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F3>', ':<C-U>setlocal lcs=tab:>-,trail:-,eol:$ list! list?<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F6>', ':NERDTreeToggle<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent> <Leader>+', ':vertical resize +25<<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<silent> <Leader>-', ':vertical resize -25<<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<buffer> <Leader>cf', ':<C-u>ClangFormat<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', 'K', ':call ShowDocumentation()<CR>', { noremap = true })

--vim.api.nvim_set_keymap('n', '<silent><nowait><expr> <C-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', { noremap = true, expr = true })
--vim.api.nvim_set_keymap('n', '<silent><nowait><expr> <C-b>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', { noremap = true, expr = true })
--vim.api.nvim_set_keymap('n', '<silent><nowait> <space>a', ':<C-u>CocList diagnostics<CR>', { noremap = true })
--vim.api.nvim_set_keymap('n', '<silent><nowait> <space>e', ':<C-u>CocList extensions<CR>', { noremap = true })
--vim.api.nvim_set_keymap('n', '<silent><nowait> <space>c', ':<C-u>CocList commands<CR>', { noremap = true })
--vim.api.nvim_set_keymap('n', '<silent><nowait> <space>o', ':<C-u>CocList outline<CR>', { noremap = true })
--vim.api.nvim_set_keymap('n', '<silent><nowait> <space>s', ':<C-u>CocList -I symbols<CR>', { noremap = true })
--vim.api.nvim_set_keymap('n', '<silent><nowait> <space>j', ':<C-u>CocNext<CR>', { noremap = true })
--vim.api.nvim_set_keymap('n', '<silent><nowait> <space>k', ':<C-u>CocPrev<CR>', { noremap = true })
--vim.api.nvim_set_keymap('n', '<silent><nowait> <space>p', ':<C-u>CocListResume<CR>', { noremap = true })

vim.api.nvim_set_keymap('n', '<c-p>', ':Telescope find_files prompt_prefix=🔍 theme=ivy<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-g>', ':Telescope live_grep<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-t>', ':Telescope treesitter<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>R', ':GrepperRg --no-ignore <C-R>=expand("<cword>")<CR><CR>', { noremap = true })

-- Key mappings (inoremap)
vim.api.nvim_set_keymap('i', '<F1>', '<ESC>', {})
-- vim.api.nvim_set_keymap('i', 'jk', '<ESC>', {}) -- Commented out due to potential conflict
vim.api.nvim_set_keymap('i', '<Bar>', '<Bar><Esc>:lua require("myplugin").align()<CR>a', { silent = true })
-- Define your function to align
local M = {}

--vim.api.nvim_set_keymap('i', '<TAB>', 'v:lua.tab_complete()', { expr = true, silent = true })
--function _G.tab_complete()
    --if vim.fn.pumvisible() == 1 then
        --return [[\<C-n>]]
    --elseif vim.fn['vsnip#available'](1) == 1 then
        --return [[\<Plug>(vsnip-expand-or-jump)]]
    --elseif check_backspace() then
        --return [[\<Tab>]]
    --else
        --return vim.fn['coc#refresh']()
    --end
--end

function check_backspace()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

--vim.api.nvim_set_keymap('i', '<expr><S-TAB>', 'coc#pum#visible() ? coc#pum#prev(1) : "<C-h>"', { expr = true })

--vim.api.nvim_set_keymap('i', '<silent><expr> <c-space>', 'coc#refresh()', { expr = true })

-- Key mappings (vnoremap)
vim.api.nvim_set_keymap('v', '<F1>', '<ESC>', {})
--vim.cmd([[
  --autocmd FileType c,cpp,objc vnoremap <buffer> <Leader>cf :ClangFormat<CR>
  --vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  --vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
--]])
