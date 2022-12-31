scriptencoding utf-8

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
  set fileencodings=utf-8,latin1
endif

"vim plug ----------------
call plug#begin()

" A collection of language packs for Vim.
Plug 'sheerun/vim-polyglot'
" A dark colour scheme for Vim.
Plug 'w0ng/vim-hybrid'
" A simple, easy-to-use Vim alignment plugin. (gaip*|, vipga)
Plug 'junegunn/vim-easy-align'
" Lean & mean status/tabline for vim that's light as air.
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" A Git wrapper so awesome, it should be illegal.
Plug 'tpope/vim-fugitive'
" Delete/change/add parentheses/quotes/XML-tags/much more with ease. (cs'")
Plug 'tpope/vim-surround'
" Check syntax in Vim asynchronously and fix files, with Language Server Protocol (LSP) support.
Plug 'dense-analysis/ale'
" A vim plugin to display the indention levels with thin vertical lines.
Plug 'yggdroot/indentline'
" 🌸 fzf ❤️ vim
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" ➕ Show a diff using Vim its sign column.
if has('nvim') || has('patch-8.0.902')
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif
" 🌿 General purpose asynchronous tree viewer written in Pure Vim script.
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/nerdfont.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
Plug 'lambdalisue/fern-git-status.vim'
" 🎨 An universal palette for Nerd Fonts
Plug 'lambdalisue/glyph-palette.vim'
" 🔗 The fancy start screen for Vim.
Plug 'mhinz/vim-startify'

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
set termguicolors

" WSL yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'
if executable(s:clip) " true only if in WSL
  augroup WSLYank
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
  augroup END
endif

" Plugin Settings

" <<< airline >>>
let g:airline_theme = 'base16_spacemacs'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#hunks#enabled = 1
let g:airline#extensions#branch#enabled = 1

" <<< hybrid >>>
set background=dark
if has('nvim')
  let g:hybrid_custom_term_colors = 1
endif
" let g:hybrid_reduced_contrast = 1 " Remove this line if using the default palette.
colorscheme hybrid
"highlight LineNr ctermfg=gray

" <<< EasyAlign >>>
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

let g:signify_sign_add = '' " nf-fa-plus

" <<< Fern >>>
augroup FernAutoOpen
  autocmd!
  autocmd VimEnter * ++nested Fern . -drawer -stay -reveal=%
augroup END
" let g:fern#disable_drawer_smart_quit = 0 " (default)
let g:fern#default_hidden = 1
let g:fern#renderer = "nerdfont"

" <<< glyph-palette >>>
augroup my-glyph-palette
  autocmd! *
  autocmd FileType fern,startify call glyph_palette#apply()
augroup END

" <<< vim-markdown (via vim-plyglot) >>>
" I really don't want to set them up individually, but it's just too inconvenient.
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_fenced_languages = ['csharp=cs', 'shell=sh']

" vim: ts=2 sts=-1 sw=0 et :
