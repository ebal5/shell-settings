" 
set number
set nowritebackup
set nobackup
set virtualedit=block
set backspace=indent,eol,start
set ambiwidth=double
set wildmenu

" Search
set ignorecase
set smartcase
set wrapscan
set incsearch
set hlsearch

set noerrorbells
set shellslash
set showmatch matchtime=1
set cinoptions+=:0
set cmdheight=2
set laststatus=2
set showcmd
set display=lastline
set list
set listchars=tab:^\ ,trail:~
set history=10000
hi Comment ctermfg=3
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=2
set guioptions-=T
set guioptions+=a
set guioptions-=m
set guioptions+=R
set showmatch
set smartindent
set noswapfile
set nofoldenable
set title
set clipboard=unnamed,autoselect
nnoremap <Esc><Esc> :nohlsearch<CR><Esc>
syntax on
set nrformats=
set whichwrap=b,s,h,l,<,>,[,],~
set mouse=a

" auto reload .vimrc
augroup source-vimrc
    autocmd!
    autocmd BufWritePost *vimre source $MYVIMRE | set foldmethod=marker
    autocmd BufWritePost *gvimrc if has('gui_running') source $MYGVIMRC
augroup END

" auto comment off
augroup auto_comment_off
    autocmd!
    autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o>
    autocmd Filetype html inoremap <buffer> </ </<C-x><C-o>
augroup END
