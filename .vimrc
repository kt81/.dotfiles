scriptencoding utf-8

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=utf-8,latin1
endif

set nocompatible	" Use Vim defaults (much better!)
set bs=indent,eol,start		" allow backspacing over everything in insert mode
"set ai			" always set autoindenting on
"set backup		" keep a backup file
set viminfo='20,\"50	" read/write a .viminfo file, don't store more
			" than 50 lines of registers
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time

" Only do this part when compiled with support for autocommands
if has("autocmd")
  augroup redhat
    " In text files, always limit the width of text to 78 characters
    autocmd BufRead *.txt set tw=78
    " When editing a file, always jump to the last cursor position
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif
  augroup END
endif

if has("cscope") && filereadable("/usr/bin/cscope")
   set csprg=/usr/bin/cscope
   set csto=0
   set cst
   set nocsverb
   " add any database in current directory
   if filereadable("cscope.out")
      cs add cscope.out
   " else add database pointed to by environment
   elseif $CSCOPE_DB != ""
      cs add $CSCOPE_DB
   endif
   set csverb
endif


"basic settings
set nocompatible
set number
set ruler
set cmdheight=1
set laststatus=1
set confirm
set whichwrap=b,s,h,l,<,>,[,]
set fileencoding=utf-8

"disable beep
set visualbell
set t_vb=

"auto load filetype plugins
filetype indent plugin on

"syntax highlight
syntax on

"colorscheme molokai
highlight LineNr ctermfg=gray

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
"set listchars=eol:↲,trail:-,tab:»\ ,extends:$
set listchars=eol:\ ,trail:-,tab:\ \ ,extends:$

"tab indent
set tabstop=4
"set expandtab -- use \t !
set smarttab
set shiftwidth=4
set shiftround
set nowrap
