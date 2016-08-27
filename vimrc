set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

"Git wrapper - Gstatus-Gcommit-Gblame-Gedit-Gread-Gwrite
Plugin 'tpope/vim-fugitive'
"Fuzzy file - finder for vim
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
"Plugin 'honza/vim-snippets.git'
Plugin 'scrooloose/nerdcommenter.git'
"Plugin 'bling/vim-bufferline.git'
"Visulize undo tree
Plugin 'sjl/gundo.vim'
"Syntax checking
Plugin 'scrooloose/syntastic.git'
Plugin 'Valloric/YouCompleteMe'
" Motion on speed
Plugin 'easymotion/vim-easymotion'
Plugin 'SirVer/ultisnips.git'
" Snippets are separated from the engine. Add this if you want them:
Plugin 'honza/vim-snippets'
Plugin 'pangloss/vim-javascript.git'
"text filtering and alignment
Plugin 'godlygeek/tabular'
Plugin 'morhetz/gruvbox'
Plugin 'rust-lang/rust.vim'
"Rust code completion and navigation
Plugin 'racer-rust/vim-racer'
"Extended % matching for HTML,Latex
Plugin 'tmhedberg/matchit'
Plugin 'Raimondi/delimitMate'
"A few of quick commands to switch between source files and header files
"quickly
Plugin 'vim-scripts/a.vim'
Plugin 'xolox/vim-easytags'
Plugin 'xolox/vim-misc'
Plugin 'majutsushi/tagbar'
Plugin 'mileszs/ack.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'maxbrunsfeld/vim-yankstack'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-dispatch'
Plugin 'wellle/tmux-complete.vim'
"Plugin 'christoomey/vim-tmux-navigator'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'bash-support.vim'
" Web Plugins
Plugin 'mattn/emmet-vim'

call vundle#end()            " required
filetype plugin indent on    " required

"""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""
set nocompatible

if &t_Co > 2 || has("gui_running")
	syntax on
endif

"256 color terminal
set t_Co=256

"longer history
set history=10000

"better commandline
set wildmenu

"proper tab completion behavior in command line
set wildmode=longest:full,full

"mouse support
set mouse=a

"case sensitive search when there's a capital letter
set ignorecase smartcase

"tab/space stuff, insert 4 spaces with tab
set tabstop=4
set shiftwidth=4
set softtabstop=0
set smarttab
set expandtab

"highlight tabs as >--, and trailing whitespace with -
set listchars=tab:>-,trail:-
set list

"buffers remember their states
set hidden

"search as it's being typed
set incsearch

"highlight search matches
set hlsearch

"s/././g by default
set gdefault

"do not wrap searches at the end of the files
set nowrapscan

"relative line numbers
"set relativenumber
set number

set autoindent
"set smartindent

set title
set ls=2

"start scrolling at 3rd row
set scrolloff=3

"default encoding
set encoding=utf-8
set fileencoding=utf-8

"show matching brackets as they're inserted
set showmatch

"preserve undo states, backup and undo files are kept in a single dir
set undofile
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set undodir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

"make vim more responsive
set lazyredraw
set ttyfast

"reduce ESC delay
set timeout           " for mappings
set timeoutlen=1000   " default value
set ttimeout          " for key codes
set ttimeoutlen=10    " unnoticeable small value

"ignore whitespace in diffs (messes up Gdiff)
set diffopt+=iwhite

filetype plugin indent on
filetype plugin on
set ofu=syntaxcomplete#Complete

"config cscope
set nosplitright
set cscopequickfix=s-,c-,d-,i-,t-,e-,g-
set cst

if has("cscope")
    " add any database in current directory
    if filereadable(".kscope/cscope.out")
        cs add .kscope/cscope.out
    endif
endif

"custom mappings
let mapleader=","

"swap 0 and ^ behavior
noremap ^ 0
noremap 0 ^

"copy/paste clipboard
map <leader>y "+y
map <leader>p "+p

"disable highlight
nnoremap <leader><space> :noh<cr>
"remove trailing whitespace
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

"cscope mappings
nnoremap <leader>r :cs find 0 <C-R>=expand("<cword>")<CR><CR>z<CR> :cope<CR><CR>
nnoremap <leader>d :cs find 1 <C-R>=expand("<cword>")<CR><CR>z<CR> :cope<CR><CR>
nnoremap <leader>v :cs find 3 <C-R>=expand("<cword>")<CR><CR>z<CR> :cope<CR><CR>

nnoremap <leader>R :vert scs find 0 <C-R>=expand("<cword>")<CR><CR>z<CR> :cope<CR><CR>
nnoremap <leader>D :vert scs find 1 <C-R>=expand("<cword>")<CR><CR>z<CR> :cope<CR><CR>
nnoremap <leader>V :vert scs find 3 <C-R>=expand("<cword>")<CR><CR>z<CR> :cope<CR><CR>
nnoremap <leader>t :!rm -r .kscope; /usr/bin/vimscope<cr>:cs reset<cr>

"disable f1
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

"switch between last buffer with space
nnoremap <space> <C-^>

"c-hjkl to move between splits
nnoremap <c-h> <C-w>h
nnoremap <c-j> <C-w>j
nnoremap <c-k> <C-w>k
nnoremap <c-l> <C-w>l

"shortcut for closing other splits
noremap <leader>o <C-w>o

"better command mode behavior for c-n and c-p
cnoremap <c-n>  <down>
cnoremap <c-p>  <up>

"move visually correct when line is wrapped
noremap j gj
noremap k gk

"center after certain movements
noremap * *zz
noremap # #zz
noremap n nzz
noremap N Nzz
noremap ]] ]]zz
noremap [[ [[zz
noremap {{ {{zz
noremap }} }}zz

"jk to go to normal mode
"inoremap jk <esc>

"disable new line comments with o
autocmd FileType * setlocal formatoptions-=o

"colorscheme set
set background=dark
colorscheme gruvbox

"highlight current line number with a different color
highlight Highlighted ctermfg=231 ctermbg=24 cterm=NONE
highlight! link CursorLineNr Highlighted

" Maximize quickfix windows' width
function! MaxQuickfixWin()
    if &buftype ==# "quickfix"
        execute "normal! \<c-w>J"
    endif
endfunction
augroup MaxQuickfixWinGrp
    autocmd!
    autocmd BufWinEnter * call MaxQuickfixWin()
augroup END

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! AppendModeline()
  let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set :",
        \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
  let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
  call append(line("$"), l:modeline)
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

"auto close info buffer thing after completion
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

"plugin related configs start here

nnoremap <F6> :NERDTreeToggle<CR>
nnoremap <F7> :GundoToggle<CR>
nmap <F8> :TagbarToggle<CR>

"Ctrl-P tag fuzzy search
nnoremap <leader>l :CtrlPBufTagAll<cr>
"Ctrl-P buffername fuzzy search
nnoremap <leader>b :CtrlPBuffer<cr>

"emacs like shortcuts for yankstack
set <m-p>=p   " rotate yanks forward
set <m-P>=P   " rotate yanks forward

" Emmet configs just for html css files
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall"

let g:EasyMotion_leader_key="t"
"custom trigger for snippets
"let g:UltiSnipsExpandTrigger="<c-a>"
" Trigger configuration. Do not use <tab> if you use
" https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

"syntastic checkers
let g:syntastic_python_checkers = ['pylint']
"let g:syntastic_python_checkers = ['pyflakes']
"let g:syntastic_python_checkers = ['pyflakes']
"let g:syntastic_python_checkers = ['pep8'asytags_suppress_ctags_warning = 1
"""""

"vim-airline stuff
"uncomment for regular fonts
let g:airline_powerline_fonts = 1

"show file name without the path
let g:airline_section_c = '%t'

"disable whitespace check
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#hunks#enabled = 0
"let g:airline#extensions#tabline#enabled = 1

"show only column number and percentage
let g:airline_section_z = '%3p%% %3v'
let g:airline_theme = 'light'
let g:airline_mode_map = {
            \ '__' : '-',
            \ 'n'  : 'N',
            \ 'i'  : 'I',
            \ 'R'  : 'R',
            \ 'c'  : 'C',
            \ 'v'  : 'V',
            \ 'V'  : 'V',
            \ '' : 'V',
            \ 's'  : 'S',
            \ 'S'  : 'S',
            \ '' : 'S',
            \ }
"""""

"racer config
let g:racer_cmd = "racer"
