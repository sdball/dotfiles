""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BUNDLES
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Vundle plugins
Plugin 'ervandew/supertab'
Plugin 'kana/vim-scratch'
Plugin 'kien/ctrlp.vim'
Plugin 'mileszs/ack.vim'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-dispatch'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'vim-ruby/vim-ruby'
Plugin 'xolox/vim-colorscheme-switcher'
Plugin 'xolox/vim-misc'

" Vundle colorschemes
Plugin 'chriskempson/base16-vim'
Plugin 'ciaranm/inkpot'
Plugin 'gosukiwi/vim-atom-dark'
Plugin 'morhetz/gruvbox'
Plugin 'sickill/vim-monokai'
Plugin 'vim-scripts/darktango.vim'
Plugin 'vim-scripts/C64.vim'
Plugin 'w0ng/vim-hybrid'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BASIC EDITING CONFIGURATION
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" allow unsaved background buffers and remember marks/undo for them
set hidden
" remember more commands and search history
set history=10000
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set laststatus=2
set showmatch
set incsearch
set hlsearch
" make searches case-sensitive only if they contain upper-case characters
set ignorecase smartcase
" highlight current line
set cursorline
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
" Store temporary files in a central spot
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
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

  "for ruby, autoindent with two spaces, always expand tabs
  autocmd FileType ruby,haml,eruby,yaml,html,javascript,sass,cucumber set ai sw=2 sts=2 et
  autocmd FileType python set sw=4 sts=4 et

  autocmd! BufRead,BufNewFile *.sass setfiletype sass

  autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
  autocmd BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;

  " Don't syntax highlight markdown because it's often wrong
  autocmd! FileType mkd setlocal syn=off
  autocmd! FileType markdown setlocal syn=off
  autocmd! FileType md setlocal syn=off
  autocmd! FileType modula2 setlocal syn=off
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COLOR
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
  map <F5> :source ~/.vimrc_background<CR>
else
  set background=dark
  colorscheme default
endif

map <F5> :let &background = ( &background == "dark"? "light" : "dark" )<CR>
let g:colorscheme_switcher_define_mappings=0
let g:colorscheme_switcher_exclude_builtins=1
let g:colorscheme_switcher_exclude = ["base16-3024","base16-apathy","base16-ashes","base16-atelierdune","base16-atelierforest","base16-atelierheath","base16-atelierlakeside","base16-atelierseaside","base16-bespin","base16-brewer","base16-bright","base16-chalk","base16-codeschool","base16-colors","base16-default","base16-eighties","base16-embers","base16-flat","base16-google","base16-grayscale","base16-greenscreen","base16-harmonic16","base16-isotope","base16-londontube","base16-marrakesh","base16-mocha","base16-monokai","base16-ocean","base16-paraiso","base16-pop","base16-railscasts","base16-shapeshifter","base16-solarized","base16-summerfruit","base16-tomorrow","base16-twilight"]
map <Left> :PrevColorScheme<cr>
map <Right> :NextColorScheme<cr>
map <Up> :RandomColorScheme<cr>
map <Down> :colors default<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" STATUS LINE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" just a bit of cartography
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader=","
map <leader>y "*y
" Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
" Insert a hash rocket with <c-l>
imap <c-l> <space>=><space>
" insert current datetime
imap <c-d> <c-R>=strftime("%c")<cr>
" Can't be bothered to understand ESC vs <c-c> in insert mode
imap <c-c> <esc>
" Clear the search buffer when hitting return
:nnoremap <CR> :nohlsearch<cr>
nnoremap <leader><leader> <c-^>
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>
" open files in directory of current file
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
" map to current file for command mode
cnoremap $$ <C-R>=expand('%')<cr>
" TESTING, WOO!
nnoremap <leader>. :call OpenTestAlternate()<cr>
map <leader>t :call RunTestFile()<cr>
map <leader>T :call RunNearestTest()<cr>
" rails maps
map <leader>gr :topleft :split config/routes.rb<cr>
map <leader>rr :call ShowRoutes()<cr>
" ctrl-p searches
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files --others --cached --exclude-standard']
map <leader>pa :CtrlPClearCache<cr>\|:CtrlP app<cr>
map <leader>pc :CtrlPClearCache<cr>\|:CtrlP config<cr>
map <leader>pl :CtrlPClearCache<cr>\|:CtrlP lib<cr>
map <leader>pp :CtrlPClearCache<cr>\|:CtrlP public<cr>
map <leader>ps :CtrlPClearCache<cr>\|:CtrlP spec<cr>
map <leader>pn :CtrlPClearCache<cr>\|:CtrlP vendor<cr>
map <leader>pt :CtrlPClearCache<cr>\|:CtrlPTag<cr>
map <leader>/ :CtrlPLine<cr>
" ruby
map <leader>pg :topleft 100 :split Gemfile<cr>
" notes
map <leader>wl :topleft :split ~/worklog/worklog.md<cr>
" when nested too deep
nnoremap <leader>x :set cursorcolumn!<cr>
" remove trailing whitespace
nnoremap <Leader>rtw :%s/\s\+$//e<CR>
nnoremap <Leader>raw :%s/\s\+$//e<CR>
" toggle numbers
map <leader># :set number!<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PASTE MODE SANITY
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set pastetoggle=<leader>v
set showmode

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"function! InsertTabWrapper()
    "let col = col('.') - 1
    "if !col || getline('.')[col - 1] !~ '\k'
        "return "\<tab>"
    "else
        "return "\<c-p>"
    "endif
"endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BIG RED UNWANTED WHITESPACE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /(\s\+$|\t)/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SWITCH BETWEEN TEST AND PRODUCTION CODE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! OpenTestAlternate()
  let new_file = AlternateForCurrentFile()
  exec ':e ' . new_file
endfunction
function! AlternateForCurrentFile()
  let current_file = expand("%")
  let new_file = current_file
  let in_spec = match(current_file, '^spec/') != -1
  let going_to_spec = !in_spec
  let in_app = match(current_file, '\<controllers\>') != -1 || match(current_file, '\<models\>') != -1 || match(current_file, '\<views\>') != -1 || match(current_file, '\<services\>') != -1 || match(current_file, '\<helpers\>') != -1
  if going_to_spec
    if in_app
      let new_file = substitute(new_file, '^app/', '', '')
    end
    let new_file = substitute(new_file, '\.rb$', '_spec.rb', '')
    let new_file = 'spec/' . new_file
  else
    let new_file = substitute(new_file, '_spec\.rb$', '.rb', '')
    let new_file = substitute(new_file, '^spec/', '', '')
    if in_app
      let new_file = 'app/' . new_file
    end
  endif
  return new_file
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

" Run the tests for the previously-marked file.
    let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_test.rb\)$') != -1
    if in_test_file
        call SetTestFile()
    elseif !exists("t:sdb_test_file")
        return
    end

    call RunTests(t:sdb_test_file, command_suffix)
endfunction

function! RunNearestTest()
    let spec_line_number = line('.')
    call RunTestFile(spec_line_number)
endfunction

function! SetTestFile()
" Set the spec file that tests will be run for.
    let t:sdb_test_file=@%
endfunction

function! RunTests(filename, line_number)
" Write the file and run tests for the given filename
    :w
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    if a:filename =~ "spec"
        if filereadable("Gemfile")
            let command="bundle exec rspec"
        else
            let command="rspec"
        end

        if a:line_number
            exec ":!" . command . " " . a:filename . ":" . a:line_number
        else
            exec ":!" . command . " " . a:filename
        end
    else
        if a:line_number
            let test_name=system("head -n " . a:line_number . " " . a:filename . " | grep 'def test_' | tail -1 | sed -e 's/.*def //'")
            exec ":!ruby -I'lib:test' " . a:filename . " -n " . test_name
        else
            exec ":!ruby -I'lib:test' " . a:filename
        end
    end
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RAILS STUFFS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! ShowRoutes()
" Requires 'scratch' plugin
  :topleft 100 :split __Routes__
" Make sure Vim doesn't write __Routes__ as a file
  :set buftype=nofile
" Delete everything
  :normal 1GdG
" Put routes output in buffer
  :0r! rake -s routes
" Size window to number of lines (1 plus rake output length)
  :exec ":normal " . line("$") . _ "
" Move cursor to bottom
  :normal 1GG
" Delete empty trailing line
  :normal dd
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CTRLP STUFFS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_max_height = 30
let g:ctrlp_mruf_relative = 1
let g:ctrlp_working_path_mode = 'w'
command! CtrlPLine call ctrlp#init(ctrlp#line#id())

