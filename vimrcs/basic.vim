" ===============
" Base
" ===============

let mapleader = ","

" Enable filetype plugins
filetype plugin on
filetype indent on

" Autocompletion enhancement
set wildmenu
set wildignore=*.o,*.pyc,*/.git/*

set history=500
set cursorline
set number
set relativenumber
set ruler
set cmdheight=2
set showcmd

" Grep-like regexes
set magic

" Ignore unsaved changes when switching buffers
set hidden
set backspace=start,indent

" Ignore case, when there is no uppercase
set ignorecase
set smartcase

" Highlight search results, display while being written
set hlsearch
set incsearch

" If changed outside vim, re-read
set autoread

" Show matching brackets on cursor, blink 2 tenths of seconds
set showmatch
set mat=2

" Add one column margin on the left
set foldcolumn=1

" Always display status, better format
set laststatus=2
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c

" ===================
" Colors and fonts
" ===================

syntax enable
colorscheme peaksea
set background=dark

" Use Unix as the standard file type
set ffs=unix,dos,mac

" =============
" Tabs stuff
" =============
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set shiftround
set autoindent
set smartindent

" ===============
" Folding
" ===============

set foldmethod=indent
set foldnestmax=3
set foldenable

" Behavior on switching buffers
set switchbuf=useopen,usetab,newtab
set stal=2

" ==================
" Mappings
" ==================

if exists("yankstack_yank_keys")
  call yankstack#setup()
endif

" Disable highlight - using leader + CR or ESC
map <silent> <leader><cr> :noh<cr>

" Visual mode => * / # searches pattern
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

" Special SPICY stuff
map <space> :tabnext<cr>
map <leader>r :read !
nmap Y y$

" Easier way to move around
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Close current buf, all buf
map <leader>bd :Bclose<cr>:tabclose<cr>gT
map <leader>ba :bufdo bd<cr>
map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

" Open new tab, close all tabs except current, close current
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Opens a new tab with the current buffer's path
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Move line using Alt+jk
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

map <leader>s :shell<cr>

" Fast edit vimrc
map <leader>e :e! ~/.vim_runtime/vimrc<cr>
autocmd! bufwritepost ~/.vimruntime/vimrc source ~/.vimruntime/vimrc

" Bash like keys for the command line
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-K> <C-U>

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" ================
" Abreviations
" ================

iab xdate <c-r>=strftime("%d/%m/%y %H:%M:%S")<cr>

" =============================
" Text rendering
" =============================

set encoding=utf8

set linebreak
set textwidth=80
set scrolloff=6

set display+=lastline

" =======================
" Misc
" =======================

" Delete comment chars on joining lines
set formatoptions+=j

" Turn backup / swap off
set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Ack searching and cope displaying
"    requires ack.vim - it's much better than vimgrep/grep
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use the the_silver_searcher if possible (much faster than Ack)
if executable('ag')
  let g:ackprg = 'ag --vimgrep --smart-case'
endif

" When you press gv you Ack after the selected text
vnoremap <silent> gv :call VisualSelection('gv', '')<CR>

" Open Ack and put the cursor in the right position
map <leader>g :Ack

" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>

" Do :help cope if you are unsure what cope is. It's super useful!
"
" When you search with Ack, display your results in cope by doing:
"   <leader>cc
"
" To go to the next search result do:
"   <leader>n
"
" To go to the previous search results do:
"   <leader>p
"
map <leader>cc :botright cope<cr>
map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
map <leader>n :cn<cr>
map <leader>p :cp<cr>

" =========================
" Perf
" =========================

" don't redraw while executing scripts
set lazyredraw
set complete-=i

"===================
" Auto stuff
" ==================

" Keep undos stored
set undodir=~/.vim_runtime/temp_dirs/undodir
set undofile

" Delete trailing white space on save
fun! CleanTrailingSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

autocmd BufWritePre * :call CleanTrailingSpaces()

" =====================
" Helpers
" =====================

" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

" Return to last edit position when opening files
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

function! CmdLine(str)
    call feedkeys(":" . a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
