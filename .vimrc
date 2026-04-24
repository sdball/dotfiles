""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BUNDLES
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
filetype off
let g:polyglot_disabled = ['jenkins', 'markdown']
let g:coc_available = 0
let g:ale_disable_lsp = 1 " let coc handle LSP
let mapleader=","

" -- Plugins: https://github.com/junegunn/vim-plug ---------------------------
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')

Plug 'ciaranm/detectindent'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " fuzzy finder
Plug 'junegunn/fzf.vim' " fuzzy finder
call plug#end()
" -- End Plugins -------------------------------------------------------------

" Machine local setup
if filereadable(expand("~/work/vimrc"))
  source ~/work/vimrc
endif

" Use the system clipboard instead of internal
set clipboard=unnamed

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BASIC EDITING CONFIGURATION
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" allow unsaved background buffers and remember marks/undo for them
set hidden
" remember more commands and search history
set history=10000
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set laststatus=2
set showmatch
set incsearch
set hlsearch
" make searches case-sensitive only if they contain upper-case characters
set ignorecase smartcase
" highlight current line
set cursorline
" more space for messages
set cmdheight=2
set switchbuf=useopen
set numberwidth=1
set number
set showtabline=2
set winwidth=100
set shell=bash
" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=
" keep more context when scrolling off the end of a buffer
set scrolloff=3
" No backups
set nobackup
set nowritebackup
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
" display incomplete commands
set showcmd
" Enable highlighting for syntax
syntax on
" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on
" zsh-style completion
set wildmode=full
" make tab completion for files/buffers act like bash
set wildmenu

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CUSTOM AUTOCMDS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup vimrcEx
  " Clear all autocmds in the group
  autocmd!
  autocmd FileType text setlocal textwidth=78
  " Jump to last cursor position unless it's invalid or in an event handler
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " spaces
  autocmd FileType ruby,haml,eruby,yaml,toml,html,sh set ai sw=2 sts=2 et

  " python autocmds
  autocmd FileType python set sw=4 sts=4 et
  autocmd FileType python let t:command="python -m pytest -s"
  autocmd FileType python let t:all_command="python -m pytest -s"
  autocmd FileType python map <leader>2 :wall\|:!python2 -m pytest -s %<cr>
  autocmd FileType python map <leader>3 :wall\|:!python3 -m pytest -s %<cr>
  autocmd FileType python let t:style_command="black \"%\""

  " javascript autocmds
  autocmd FileType javascript set ai sw=2 sts=2 et
  autocmd FileType javascript let t:command="npm test"

  " shell autocmds
  autocmd FileType sh let t:style_command="shellcheck --shell=bash --exclude=SC2164,SC2001,SC2002,SC2006 \"%\""
  autocmd FileType sh map <leader>r :wall\|:!./%<cr>
  autocmd FileType zsh map <leader>r :wall\|:!./%<cr>

  autocmd FileType ruby map <leader>r :wall\|:!ruby %<cr>

  if filereadable(expand("~/work/autocmds.vim"))
    source ~/work/autocmds.vim
  endif

  " open yaml files with all folds open
  autocmd FileType yaml normal zR
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COLOR
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if filereadable(expand("~/.vimrc_background"))
  if has("termguicolors")
    set termguicolors
  endif
  let base16colorspace=256
  source ~/.vimrc_background
  map <F5> :source ~/.vimrc_background<CR>
else
  colorscheme default
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" STATUS LINE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" just a bit of cartography
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Store a session
map <leader>m :mksession! /tmp/vim-session<cr>\|:wqall<cr>

" Yank a movement
map <leader>y "*y

" Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" some frequent code inserts
imap <c-l> <space>=><space>

" Can't be bothered to understand ESC vs <c-c> in insert mode
imap <c-c> <esc>

" Clear the search buffer when hitting return
:nnoremap <CR> :nohlsearch<cr>

" Jump to previous file
nnoremap <leader><leader> <c-^>

" open files in directory of current file
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%

" map to current file for command mode
cnoremap $$ <C-R>=expand('%')<cr>

" when nested too deep
nnoremap <leader>x :set cursorcolumn!<cr>

" toggle numbers
map <leader># :set number!<cr>

" :W should really be :w because I never want :W and always mean :w
" :Q should really be :q because Q doesn't even do anything
" put them together and magic
command WQ wq
command Wq wq
command W w
command Q q

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PASTE MODE MORE REASONABLE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set pastetoggle=<leader>v
set showmode

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" HIGHLIGHT BIG RED UNWANTED WHITESPACE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /(\s\+$|\t)/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FZF                                                                        "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
" --color: Search color options
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h | %<(20,trunc)%an | %s"'

map <C-p> :Files<cr>
map <C-g> :Rg<space>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

