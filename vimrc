" Don't override any settings when started as 'evim'
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Pathogen is used to automatically load any plugins placed in the
" ~/.vim/bundle subdirectory.
" To disable a pathogen plugin, add it's bundle name to the following list
" e.g. call add(g:pathogen_disabled, 'unimpaired')
let g:pathogen_disabled = []
"call add(g:pathogen_disabled, 'abolish')
"call add(g:pathogen_disabled, 'ansible-vim')
"call add(g:pathogen_disabled, 'bufexplorer')
"call add(g:pathogen_disabled, 'clang_complete')
"call add(g:pathogen_disabled, 'commentary')
"call add(g:pathogen_disabled, 'fugitive')
"call add(g:pathogen_disabled, 'go')
"call add(g:pathogen_disabled, 'snippets')
"call add(g:pathogen_disabled, 'supertab')
"call add(g:pathogen_disabled, 'surround')
"call add(g:pathogen_disabled, 'tabular')
"call add(g:pathogen_disabled, 'ultisnips')
"call add(g:pathogen_disabled, 'undotree')
"call add(g:pathogen_disabled, 'unimpaired')
"call add(g:pathogen_disabled, 'valgrind')
"call add(g:pathogen_disabled, 'vim-airline')
"call add(g:pathogen_disabled, 'vim-airline-themes')
"call add(g:pathogen_disabled, 'visual-star-search')

" Load pathogen
execute pathogen#infect()

" Allow backspacing in insert mode over autoindents, line breaks (join
" lines) and over start of insert
set backspace=indent,eol,start

set history=200		" keep 200 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" Show line breaks and other blank characters
set showbreak=⤹
set listchars=tab:⤑\ ,trail:·,extends:…,precedes:…,nbsp:␣
set list

" Remove the toolbar and scrollbar in gvim
set guioptions-=T
set guioptions-=r

" Remap the Q key from entering ex-mode into triggering text formatting
map Q gq

" Map 'ö' to ';' and 'Ö' to ',', search next/prev matching char
nmap ö ;
nmap Ö ,

" Traverse the change list using 'gö' and 'gÖ'
nmap gö g;
nmap gÖ g,

" CTRL-U in insert mode deletes a lot. Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Remap the cursor row up(k)/down(j) commands to work on display lines rather
" than real lines
nnoremap j gj
nnoremap gj j
nnoremap k gk
nnoremap gk k

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Only do this when running in gvim or a color terminal
if &t_Co > 2 || has("gui_running")
  " Switch syntax highlighting on
  syntax on

  " Switch on highlighting the last used search pattern.
  set hlsearch

  " Load a nice colorscheme and modify it slightly
  colorscheme desert
  highlight NonText guibg=gray20
  highlight LineNr guifg=lightblue guibg=gray25
  highlight CursorLineNr guifg=lightblue guibg=gray25 term=bold
  highlight CursorLine guibg=gray25
  highlight CursorColumn guibg=gray25
endif

" Only do this when running in gvim
if has("gui_running")
  " Highlight the current cursor line
  set cursorline

  " Force window size to a fixed size
  set columns=85
  set lines=35

  " Set up a good programming font
  " set guifont=DejaVu\ Sans\ Mono\ 11
  " set guifont=inconsolata\ 15
  " set guifont=Liberation\ Mono\ for\ Powerline\ 11
  set guifont=Droid\ Sans\ Mono\ Dotted\ for\ Powerline\ 11

  " Show syntax highlighting groups for word under cursor when Ctrl-Shift-P
  " is pressed
  nmap <C-S-P> :call <SID>SynStack()<CR>
  function! <SID>SynStack()
    if !exists("*synstack")
      return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
  endfunc
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  augroup vimrc
    " Delete all existing autoCmds in this autoCmd group to avoid duplicates
    " when sourcing the .vimrc file multiple times
    autocmd!

    " For all text files set 'textwidth' to 78 characters.
    "autocmd FileType text setlocal textwidth=78 formatoptions+=a
    autocmd FileType text setlocal textwidth=78

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    " Also don't do it when the mark is in the first line, that is the default
    " position when opening a file.
    autocmd BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif

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

    "autocmd FileType go :call GoSetup()
    "autocmd FileType python :call PythonSetup()

    " Reread the .vimrc file whenever it is saved
    "autocmd BufWritePost .vimrc source $MYVIMRC
  augroup END
else
  " Enable built in autoindent if no autocmd handling is available
  set autoindent
endif

"fun! GoSetup()
"  set shiftwidth=4
"  set softtabstop=4
"  set tabstop=4
"endfun

"fun! PythonSetup()
"  set shiftwidth=4
"  set softtabstop=4
"  set tabstop=4
"endfun

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
"if !exists(":DiffOrig")
"  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
"		  \ | wincmd p | diffthis
"endif

" Indent using two spaces by default
set expandtab
set shiftwidth=2
set softtabstop=2

" Enable tags reading
" Recursively generate tags for a source tree using: ctags -R .
"set tags=./tags;

" For snipMate
"let g:snippets_dir = "~/.vim/local.snippets,~/.vim/snippets"

" Allow more than 10 tabs to be opened
set tabpagemax=20

" Switch tabs using Shift+H and Shift+L
nnoremap <S-H> :tabprev<CR>
nnoremap <S-L> :tabnext<CR>

" Move tabs using Ctrl+Shift+H and Ctrl-Shift+L
map <C-S-H> :-tabmove<CR>
map <C-S-L> :+tabmove<CR>

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

" Set up cindent options
"   Indent comments one step
set cino=/1s

" Open manual page for word or visual selection under cursor.  The F1 command
" may be prefixed with the number of the man section to search in.
runtime ftplugin/man.vim
nnoremap <F1> :<C-U>exe ":Man " . v:count1 . " " . expand('<cword>')<CR>
vnoremap <F1> y:exe ':Man <C-r>"'<CR>
for i in [0,1,2,3,4,5,6,7,8,9,'n']
  :exe "vnoremap " . i . "<F1> y:exe ':Man " . i . " <C-r>\"'<CR>"
endfor
"vmap nK y:exe ':Man n <C-r>"'<CR>

" Use '§' as leader key instead of backslash
let mapleader='§'

" Open file in the same directory as the current file
" Typing %% will expand to the path to the current directory
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" Navigate the quickfix list using friendlier keys for Swedish keyboards
map <leader>k :cp<CR>
map <leader>j :cn<CR>

" Toggle quickly between paste/nopaste
set pastetoggle=<leader>p

" Show hybrid (relative and current absolute) line numbering when focused and
" input mode is not 'insert'
set number
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" Allow switching from a buffer even if there are unsaved data
set hidden

" Bubble single/multiple lines up or down (using the unimpaired plugin)
nmap <A-Up> V[egv
nmap <A-Down> V]egv
vmap <A-Up> [egv
vmap <A-Down> ]egv

" In addition to redrawing the screen, also clear search highligting
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" Fix the & command so that it repeats the last search/replace command
" including the flags used
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" Set up Gundo configuration variables
" let g:gundo_width = 30
" let g:gundo_preview_height = 15
" let g:gundo_preview_bottom = 1
" let g:gundo_right = 0
" let g:gundo_help = 1
" let g:gundo_disable = 1
" let g:gundo_close_on_revert = 0
" let g:gundo_auto_preview = 1
" let g:gundo_return_on_revert = 1
" Toggle Gundo view using F5
" nnoremap <F5> :GundoToggle<CR>

" Settings for the Undotree plugin
let g:undotree_WindowLayout = 2
let g:undotree_HelpLine = 0
let g:undotree_DiffCommand = "diff -u"
let g:undotree_DiffpanelHeight = 15
let g:undotree_DiffAutoOpen = 1
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_TreeNodeShape = '*'
let g:undotree_RelativeTimestamp = 1
let g:undotree_ShortIndicators = 1
if has("persistent_undo")
  set undodir=~/.vimundodir/
  set undofile
endif
nnoremap <F5> :UndotreeToggle<CR>

" UltiSnips trigger configuration
let g:UltiSnipsEditSplit="horizontal"
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
let g:UltiSnipsSnippetsDir = "~/.vim/local.snippets"

" Vim-airline plugin configuration
set laststatus=2
let g:airline#extensions#whitespace#enabled = 0
let g:airline_theme='bubblegum'
let g:airline_powerline_fonts = 1

" Netrw default directory browsing is tree view
let g:netrw_liststyle = 3
