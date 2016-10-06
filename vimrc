" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" To disable a pathogen plugin, add it's bundle name to the following list
" e.g. call add(g:pathogen_disabled, 'unimpaired')
let g:pathogen_disabled = []
call add(g:pathogen_disabled, 'snipMate')

" Load pathogen
execute pathogen#infect()

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=200	        " keep 200 lines of command line history
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

" Only do this when running in gvim or a color terminal
if &t_Co > 2 || has("gui_running")
  " Switch syntax highlighting on, when the terminal has colors
  syntax on
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Only do this when running in gvim
if has("gui_running")
  " Highlight the current cursor line
  set cursorline
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
  autocmd FileType go :call PythonSetup()

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

fun! PythonSetup()
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

" For snipMate
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
highlight LineNr guifg=lightblue guibg=gray25
highlight CursorLineNr guifg=lightblue guibg=gray25 term=bold
highlight CursorLine guibg=gray25

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

" By default put copied text into the desktop clipboard.
if has("unnamedplus")
  set clipboard=unnamedplus
endif

" Do some special settings if using gvim
if has("gui_running")
  " Force window size to 80x35 characters.
  set columns=85
  set lines=35
  
  " Set up a good programming font
  " set guifont=DejaVu\ Sans\ Mono\ 11
  set guifont=inconsolata\ 15
endif

" Set up cindent options
"   Indent comments one step
set cino=/1s

" Open manual page for word or visual selection under cursor.
" In normal mode, the K command may be prefixed with the number
" of the man section to search in.
runtime ftplugin/man.vim
nmap K :<C-U>exe ":Man " . v:count1 . " " . expand('<cword>')<CR>
vmap K y:exe ':Man <C-r>"'<CR>
for i in [0,1,2,3,4,5,6,7,8,9,'n']
  :exe "vmap " . i . "K y:exe ':Man " . i . " <C-r>\"'<CR>"
endfor
"vmap nK y:exe ':Man n <C-r>"'<CR>

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

" Allow switching from a buffer even if there are unsaved data
set hidden

" Bubble single/multiple lines up or down (using the unimpaired plugin)
nmap <A-Up> V[egv
nmap <A-Down> V]egv
vmap <A-Up> [egv
vmap <A-Down> ]egv

" Set up Gundo configuration variables
let g:gundo_width = 30
let g:gundo_preview_height = 15
let g:gundo_preview_bottom = 1
let g:gundo_right = 0
let g:gundo_help = 1
let g:gundo_disable = 0
let g:gundo_close_on_revert = 0
let g:gundo_auto_preview = 1
let g:gundo_return_on_revert = 1
" Toggle Gundo view using F5
nnoremap <F5> :GundoToggle<CR>

" UltiSnips trigger configuration
let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<c-b>"
"let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"
