" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Load pathogen
execute pathogen#infect()

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" Set chars for the show blanks function
set listchars=tab:▸\ ,eol:¬,trail:·

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78 formatoptions+=a

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

  " Automatically open, but do not go to (if there are errors) the quickfix /
  " location list window, or close it when is has become empty.
  "
  " Note: Must allow nesting of autocmds to enable any customizations for
  " quickfix buffers.
  " Note: Normally, :cwindow jumps to the quickfix window if the command opens
  " it (but not if it's already open). However, as part of the autocmd, this
  " doesn't seem to happen.
  autocmd QuickFixCmdPost [^l]* nested cwindow
  autocmd QuickFixCmdPost    l* nested lwindow

  autocmd FileType go :call GoSetup()

  " Reread the .vimrc file whenever it is saved
  "autocmd BufWritePost .vimrc source $MYVIMRC
else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

fun! GoSetup()
  set shiftwidth=4
  set softtabstop=4
  set tabstop=4
endfun

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" Indent using two spaces
set expandtab
set shiftwidth=2
set softtabstop=2

" Enable tags reading
" Recursively generate tags for a source tree using: ctags -R .
set tags=./tags;

let g:snippets_dir = "~/.vim/local.snippets,~/.vim/snippets"

" Allow more than 10 tabs to be opened
set tabpagemax=20

" Switch tabs using Ctrl+LEFT and Ctrl+RIGHT
map <S-LEFT> :tabprev<CR>
map <S-RIGHT> :tabnext<CR>

" Move tabs using Ctrl+Shift+LEFT and Ctrl-Shift+RIGHT
map <C-S-LEFT> :-tabmove<CR>
map <C-S-RIGHT> :+tabmove<CR>

" Load a nice colorscheme and modify it slightly
colorscheme desert
highlight NonText guibg=gray20
highlight LineNr guifg=lightblue guibg=#444444
highlight CursorLineNr guifg=lightblue guibg=#444444 term=bold

" Show syntax highlighting groups for word under cursor when Ctrl-Shift-P
" is pressed
nmap <C-S-P> :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" Set sensible tab completion
set wildmode=longest,list,full
set wildmenu

" Buffers - explore/next/previous: Alt-F12, F12, Shift-F12.
nnoremap <silent> <M-F12> :BufExplorer<CR>
nnoremap <silent> <F12> :bn<CR>
nnoremap <silent> <S-F12> :bp<CR>

" Do some special settings if using gvim
if has("gui_running")
  " Force window size to 80x35 characters.
  set columns=85
  set lines=35
  
  " By default put copied text into the desktop clipboard.
  set clipboard=unnamedplus

  " Set up a good programming font
  " set guifont=DejaVu\ Sans\ Mono\ 11
  set guifont=inconsolata\ 15
endif

" Set up cindent options
"   Indent comments one step
set cino=/1s

" Open manual page for word under cursor
fun! ReadMan()
  " Assign current word under cursor to a script variable:
  let s:man_word = expand('<cword>')
  " Open a new window:
  :exe ":wincmd n"
  " Read in the manpage for man_word (col -b is for formatting):
  :exe ":r!man " . s:man_word . " | col -b"
  " Goto first line...
  :exe ":goto"
  " and delete it:
  :exe ":delete"
  " finally set file type to 'man':
  :exe ":set filetype=man"
endfun
" Map the K key to the ReadMan function:
map K :call ReadMan()<CR>

" Use comma as leader key instead of backslash
let mapleader=','

" Open file in the same directory as the current file
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" Indicate wrapped lines using the ellipsis character
set showbreak=…

" Show relative line numbering
set relativenumber

" Bubble single/multiple lines up or down
nmap <A-Up> V[egv
nmap <A-Down> V]egv
vmap <A-Up> [egv
vmap <A-Down> ]egv

" Highlight the current cursor line
set cursorline
