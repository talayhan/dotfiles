set encoding=utf-8
set fileencoding=utf-8
set ignorecase
set undofile
set textwidth=118
set number
set hlsearch
set incsearch
set autochdir
set splitright
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set scrolloff=10
set mouse=a
set bs=indent,eol,start
set clipboard+=unnamedplus
set history=1000
set relativenumber

map <C-n> :NERDTreeToggle<CR>
" Per Project Vimrc
set exrc

" Bindings
nmap <Tab> :CtrlPBuffer<CR>
map <C-h> :CtrlPLine<CR>
imap <S-Tab> <Esc><<i
nmap - :NERDTreeToggle<CR>
nmap <F8> :TagbarToggle<CR>

" bash-comment
let g:BASH_AuthorName   = 'Talayhan Samet'     
let g:BASH_AuthorRef    = '@talayhans'                         
let g:BASH_Email        = 'samet.talayhan@gmail.com'            
let g:BASH_Company      = 'talayhan.xyz'    

" ultisnips
let g:UltiSnipsExpandTrigger="<c-tab>"
let g:UltiSnipsListSnippets="<c-l>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" vim-markdown
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh']
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" vim-airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = "badwolf"

call plug#begin('~/.vim/plugged')

" Make sure you use single quotes
Plug 'junegunn/seoul256.vim'
Plug 'junegunn/vim-easy-align'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using git URL
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Using a non-master branch
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
Plug 'bling/vim-airline'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/syntastic'
Plug 'SirVer/ultisnips'
Plug 'airblade/vim-gitgutter'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'kien/ctrlp.vim'
Plug 'tpope/vim-markdown'
Plug 'Valloric/YouCompleteMe'
Plug 'honza/vim-snippets'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'Raimondi/delimitMate'

" Plugin options
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Add plugins to &runtimepath
call plug#end()

syntax on
colorscheme molokai
let g:rainbow_active = 1
let g:auto_save = 1
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%120v', 100)
set listchars=tab:>~,nbsp:_,trail:.
set list

