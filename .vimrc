""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BUNDLES
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
filetype off

" -- Plugins: https://github.com/junegunn/vim-plug ---------------------------
call plug#begin('~/.vim/plugged')

Plug 'AndrewRadev/switch.vim'
Plug 'chriskempson/base16-vim'
Plug 'conormcd/matchindent.vim'
Plug 'elixir-lang/vim-elixir', { 'for': 'elixir' }
Plug 'ervandew/supertab'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'leafgarland/typescript-vim'
Plug 'pangloss/vim-javascript'
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rails', { 'for': 'ruby' }
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'

call plug#end()
" -- End Plugins -------------------------------------------------------------

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

  autocmd FileType ruby,haml,eruby,yaml,html,sass,cucumber set ai sw=2 sts=2 et
  autocmd FileType python set sw=4 sts=4 et
  autocmd FileType javascript set ai sw=2 sts=2 et
  autocmd FileType javascript let t:command="npm test"

  if filereadable(expand("~/.vim/work/autocmds.vim"))
    source ~/.vim/work/autocmds.vim
  endif
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
  colorscheme base16-ashes
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" STATUS LINE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" just a bit of cartography
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader=","

" Yank a movement
map <leader>y "*y

" Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Insert a hash rocket with <c-l>
imap <c-l> <space>=><space>

" insert current datetime
imap <c-d> # <c-R>=strftime("%Y-%m-%d %A")<cr>

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

" TESTING, WOO!
nnoremap <leader>. :call OpenTestAlternate()<cr>
map <leader>t :call RunTestFile()<cr>
map <leader>T :call RunNearestTest()<cr>
map <leader>a :call RunAllTests()<cr>
map <leader>s :call RunStyleChecks()<cr>

" when nested too deep
nnoremap <leader>x :set cursorcolumn!<cr>

" remove trailing whitespace
nnoremap <Leader>rtw :%s/\s\+$//e<CR>
nnoremap <Leader>raw :%s/\s\+$//e<CR>

" toggle numbers
map <leader># :set number!<cr>

" :W should really be :w because I never want :W and always mean :w
" :Q should really be :q because Q doesn't even do anything
" put them together and magic
command WQ wq
command Wq wq
command W w
command Q q

" misc
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PASTE MODE SANITY
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set pastetoggle=<leader>v
set showmode

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
" RUNNING TESTS AND STYLE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RunStyleChecks()
  if !exists("t:style_command")
    echo "Unknown global style check command"
  else
    exec ":!" . t:style_command
  end
endfunction
function! RunAllTests()
  if !exists("t:command")
    echo "Unknown global test suite command"
  else
    exec ":!" . t:command
  end
endfunction
function! RunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

" Run the tests for the previously-marked file.
    let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_test.rb\|_test.exs\|spec.js\)$') != -1
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
    " Write the open files and run tests for the given filename
    :wall
    if a:filename =~ "\.rb$"
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
            if filereadable("Gemfile")
                let command="bundle exec ruby"
            else
                let command="ruby"
            end

            if a:line_number
                let test_name=system("head -n " . a:line_number . " " . a:filename . " | rg '(def test_|test \")' | tail -1 | sed -e 's/.*def //' -e 's/.*test //' -e 's/ do$//' | tr '\"' / | tr \"'\" / | tr ' ' _")
                exec ":!" . command . " -Itest " . a:filename . " -n " . test_name
            else
                exec ":!" . command . " -Itest " . a:filename
            end
        end
    elseif a:filename =~ "\.exs$"
        let command="mix test"

        if a:line_number
            exec ":!" . command . " " . a:filename . ":" . a:line_number
        else
            exec ":!" . command . " " . a:filename
        end
    elseif a:filename =~ "\.js$"
      let current_file=expand('%')
      if a:line_number && current_file == a:filename
        " run the specific test containing the selected line by
        " - finding the relevant it or describe declaration
        " - changing it to fit or fdescribe
        " - running the filtered test file
        " - reverting the fit/fdescribe back to it/describe
        normal j
        ?\(\(^\|\s\)it\|\(^\|\s\)describe\)
        normal If
        :silent w
        let basename=system("echo -n `basename " . a:filename . "`")
        exec ':!' . t:command . ' --filter="' . basename . '"'
        normal x
        :silent w
      else
        let basename=system("echo -n `basename " . a:filename . "`")
        exec ':!' . t:command . ' --filter="' . basename . '"'
      end
    end
endfunction

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
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --glob "!_build/*" --glob "!deps/*" --glob "!.DS_Store" --glob "!public/*" --glob "!log/*" --glob "!tmp/*" --glob "!vendor/*" --glob "!.git-crypt/*" --glob "!.vagrant/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)
map <C-p> :Files<cr>
map <C-g> :Find
map <C-/> :Lines<cr>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" REVEAL
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! SetupReveal()
    let t:sdb_reveal_file="outline.txt"
    let t:sdb_reveal_line=0
endfunction

function! Reveal()
    :normal 1GdG
    let t:sdb_reveal_line=t:sdb_reveal_line + 1
    exec ":read !head -" . t:sdb_reveal_line . " " . t:sdb_reveal_file
    :normal gg
    :normal dd
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" JavaScript Business
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:javascript_conceal_function             = "ƒ"
let g:javascript_conceal_null                 = "ø"
let g:javascript_conceal_this                 = "@"
let g:javascript_conceal_return               = "⇚"
let g:javascript_conceal_undefined            = "¿"
let g:javascript_conceal_NaN                  = "ℕ"
let g:javascript_conceal_prototype            = "¶"
let g:javascript_conceal_static               = "•"
let g:javascript_conceal_super                = "Ω"
let g:javascript_conceal_arrow_function       = "⇒"
" let g:javascript_conceal_noarg_arrow_function = "🞅"
" let g:javascript_conceal_underscore_arrow_function = "🞅"
map <leader>c :exec &conceallevel ? "set conceallevel=0" : "set conceallevel=1"<CR>

