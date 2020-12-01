scriptencoding utf-8

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
  set fileencodings=utf-8,latin1
endif

"vim plug ----------------
call plug#begin()

Plug 'sheerun/vim-polyglot'
Plug 'w0ng/vim-hybrid'
Plug 'junegunn/vim-easy-align'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'yggdroot/indentline'
Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh' }
Plug 'junegunn/fzf'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

if has('nvim') || has('patch-8.0.902')
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif

call plug#end()
"/vim plug ---------------

"basic settings
set number
set ruler
set cmdheight=1
set laststatus=2
set confirm
set whichwrap=b,s,h,l,<,>,[,]
set modeline

"disable beep
set visualbell
set t_vb=

"move display line
nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up>   gk
nnoremap gj j
nnoremap gk k

"syntax highlight
syntax on

"for search
set ignorecase
set smartcase
set wrapscan
set hlsearch

"editing
set autoindent
set cindent
set showmatch
set backspace=indent,eol,start
set clipboard=unnamed
set pastetoggle=<F6>
set guioptions+=a

"list settings
set list
set listchars=eol:↲,trail:-,tab:»\ ,extends:$,space:.

"tab indent
set tabstop=4
set expandtab
set smarttab
set shiftwidth=4
set shiftround
set wrap

"mouse
set mouse=a
if !has('nvim')
  set ttymouse=xterm2
endif

set nobackup

" color
if has('nvim')
  set termguicolors
else
  set term=screen-256color
endif

" airline
let g:airline_theme = 'base16_spacemacs'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#hunks#enabled = 1
let g:airline#extensions#branch#enabled = 1

" Plugin Settings

" <<< hybrid >>>
set background=dark
if has('nvim')
  let g:hybrid_custom_term_colors = 1
endif
" let g:hybrid_reduced_contrast = 1 " Remove this line if using the default palette.
colorscheme hybrid
" highlight LineNr ctermfg=gray

" <<< EasyAlign >>>
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" <<< NERDTree >>>
" open a NERDTree automatically when vim starts up
autocmd vimenter * NERDTree
" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" get NERDTree to show dot files
let NERDTreeShowHidden=1
" go to opened file on launch
autocmd VimEnter * if argc() != 0 || exists("s:std_in") | wincmd p | endif

" <<< NERDTREE git >>>
let g:NERDTreeGitStatusUseNerdFonts = 1

" vim: ts=8 sw=2 et :
