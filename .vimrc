scriptencoding utf-8

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
  set fileencodings=utf-8,latin1
endif

"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath^=~/.vim/dein/repos/github.com/Shougo/dein.vim

" Required:
call dein#begin(expand('~/.vim/dein'))

" Let dein manage dein
" Required:
call dein#add('Shougo/dein.vim')

" Add or remove your plugins here:
call dein#add('Shougo/neosnippet.vim')
call dein#add('Shougo/neosnippet-snippets')
call dein#add('w0ng/vim-hybrid')
call dein#add('vim-scripts/nginx.vim')
call dein#add('timcharper/textile.vim')
call dein#add('vim-ruby/vim-ruby')
call dein#add('itchyny/lightline.vim')
call dein#add('Shougo/vimshell')
call dein#add('junegunn/vim-easy-align')

" Required:
call dein#end()

" Required:
filetype plugin indent on

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts----------------------

"basic settings
set number
set ruler
set cmdheight=1
set laststatus=1
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
set pastetoggle=<F3>
set guioptions+=a

"list settings
set list
set listchars=eol:↲,trail:-,tab:»\ ,extends:$

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

"powerline
"python from powerline.vim import setup as powerline_setup
"python powerline_setup()
"python del powerline_setup
"set laststatus=2
"set showtabline=2
"set noshowmode

set nobackup

" color
if has('nvim')
  set termguicolors
else
  set term=screen-256color
endif

"lightlineと同じ設定
set laststatus=2
let g:lightline = {
  \ 'colorscheme': 'wombat'
  \ }
set background=dark
let g:hybrid_custom_term_colors = 1
"let g:hybrid_reduced_contrast = 1 " Remove this line if using the default palette.
colorscheme hybrid
"highlight LineNr ctermfg=gray

" Plugin Settings
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" vim: ts=8 sw=2 et :
