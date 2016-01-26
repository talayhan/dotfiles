set nocompatible
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.
set shiftwidth=4    " Indents will have a width of 4
set softtabstop=4   " Sets the number of columns for a TAB
set expandtab       " Expand TABs to spaces

" Bundles
" source ~/.vim/bundles.vim

" Track the engine.
Plugin 'SirVer/ultisnips'

" Snippets are separated from the engine. Add this if you want them:
Plugin 'honza/vim-snippets'
Plugin 'majutsushi/tagbar'
Plugin 'Valloric/YouCompleteMe'
Plugin 'scrooloose/syntastic'
Plugin 'bling/vim-airline'
Plugin 'sjl/gundo.vim'
Plugin 'taglist.vim'
Plugin 'Shougo/unite.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'Shougo/vimfiler.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'nanotech/jellybeans.vim'

" Trigger configuration. Do not use <tab> if you use
" https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

call vundle#end()
filetype plugin indent on

" Generic
set encoding=utf-8
set fileencodings=utf-8

set autoindent
set smartindent
set cindent
set background=dark
set expandtab
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set wildignore=*.pyc
set ignorecase
set smartcase
set hlsearch
set incsearch
set shiftround
set history=1000
set undolevels=1000
set noswapfile
set nobackup
set linespace=3
set scrolloff=3
set cursorline

set relativenumber
set number

set clipboard=unnamedplus
map <C-n> :NERDTreeToggle<CR>
" Per Project Vimrc
set exrc

" Enable mouse events
if has("mouse")
  set mouse=a
endif
map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>

" Bindings
nmap <Tab> :CtrlPBuffer<CR>
map <C-h> :CtrlPLine<CR>
imap <S-Tab> <Esc><<i
nmap - :NERDTreeToggle<CR>
nmap <F8> :TagbarToggle<CR>

" Subsettings
let NERDTreeShowBookmarks=1
let g:sneak#streak=1
let g:user_emmet_mode='a'
let g:user_emmet_install_global = 0
autocmd FileType html,css,scss,less,eruby EmmetInstall
autocmd FileType html,css,scss,less,eruby imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")

let g:BASH_AuthorName   = 'Talayhan Samet'     
let g:BASH_AuthorRef    = '@talayhans'                         
let g:BASH_Email        = 'samet.talayhan@gmail.com'            
let g:BASH_Company      = 'talayhan.xyz'    

let g:airline_powerline_fonts=0
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:tmuxline_powerline_separators=0

let g:airline#extensions#syntastic#enabled=1
let g:airline#extensions#virtualenv#enabled=1
let g:airline_detect_paste=1
let g:airline_detect_modified=1

let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:5,results:15'
let g:netrw_liststyle=3

command Bash ConqueTermSplit bash --init-file ~/.bash_profile
map <silent> <S-Down> :Bash<CR>
map <silent> <C-D-Space> :Dash<CR>

" Ignore
set wildignore+=*~,*.sw?
set wildignore+=*.tar.*,*.tgz
set wildignore+=.DS_Store
set wildignore+=node_modules/*,*.min.js               " Javascript
set wildignore+=*.pyc,dist/*,build/*,*.egg-info,*.egg " Python

" Autofiletype
autocmd BufNewFile,BufReadPost *.less set ft=less
autocmd BufNewFile,BufReadPost *.coffee set ft=coffee
autocmd BufNewFile,BufReadPost *.scss set ft=scss

" Omni Completion
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Code Control
hi OverLength term=underline cterm=underline gui=undercurl guisp=Orange 
match OverLength /\%81v.\+/

" 3 esc buffer close, wow easy.
map <silent> <esc><esc><esc> :bd<CR>
imap <silent> <esc><esc><esc> <esc>:bd<CR>

" clear search
map <silent> <space><space> :let @/=''<CR>

inoremap <expr> <C-D-Space> "\<C-X>\<C-O>"

" keep blocks selected when indenting
vnoremap < <gv
vnoremap > >gv

if has('gui_running')
  set guioptions-=rL
  set guifont=Monaco:h13
  set clipboard=unnamed
  if has('gui_macvim')
    set macmeta
    set fuopt=maxvert,maxhorz
  endif
endif

source ~/.vim/functions.vim
filetype plugin on
